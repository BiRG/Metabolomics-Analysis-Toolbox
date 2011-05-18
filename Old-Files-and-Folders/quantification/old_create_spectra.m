function spectra = create_spectra(x,Y,left_noise,right_noise,all_options,filtered_list)
xwidth = abs(x(1)-x(2));

% This will be set to the optimal from the previous experiment
options = all_options.peak_finding_options;

spectra = {};
inxs = find(left_noise >= x & x >= right_noise);
nm = size(Y);
num_samples = nm(2);
num_filtered = 0;
filter_masks = {};
for s = 1:num_samples
    spectra{s}.noise_std = std(Y(inxs,s));
    spectra{s}.mean = mean(Y(inxs,s));
    [spectra{s}.y_smoothed,spectra{s}.all_maxs,spectra{s}.all_mins] = smooth(Y(:,s),spectra{s}.noise_std*options.noise_std_mult,options);
    filter_masks{s} = ones(size(spectra{s}.all_maxs));
    if exist('filtered_list') && ~isempty(filtered_list)
        for m = 1:length(spectra{s}.all_maxs)
            max_inx = spectra{s}.all_maxs(m);
            min_inxs = spectra{s}.all_mins(m,:);
            observed_peak = Y(min_inxs(1):min_inxs(end),s);
            observed_peak_x = x(min_inxs(1):min_inxs(end));
            height1 = Y(max_inx,s) - Y(min_inxs(1),s);
            height2 = Y(max_inx,s) - Y(min_inxs(end),s);
            observed_peak_min_height = min([height1,height2]);
            observed_peak_max_height = max([height1,height2]);
            tinxs = min_inxs(1):min_inxs(end);
            [vs,wixs] = sort(abs((Y(tinxs,s)-Y(min_inxs(1),s))-height1/2));
            wix = tinxs(wixs(1));
            width1 = 2*xwidth*abs(max_inx-wix);
            [vs,wixs] = sort(abs((Y(tinxs,s)-Y(min_inxs(end),s))-height2/2));
            wix = tinxs(wixs(1));
            width2 = 2*xwidth*abs(max_inx-wix);
            observed_peak_min_width = min([width1,width2]);
            observed_peak_max_width = max([width1,width2]);
            
            % Has to be fit the parameters of at least one filtered peak
            % (using pearson correlation)
            y1 = observed_peak - min(observed_peak);
            for i = 1:length(filtered_list.observed_peaks)
                y2 = interp1(1:length(filtered_list.observed_peaks{i}),filtered_list.observed_peaks{i} - min(filtered_list.observed_peaks{i}),(1:length(y1))','linear','extrap');
                SSreg = sum((y1-y2).^2);
                SStot = sum((y2 - mean(y2)).^2);
                R2 = 1 - SSreg/SStot;
                if R2 >= options.R2_threshold
                    filter_masks{s}(m) = 0;
                    num_filtered = num_filtered + 1;
                    break;
                end                        
            end
        end
    end
end
for s = 1:num_samples
    new_all_maxs = [];
    new_all_mins = [];
    for m = 1:length(spectra{s}.all_maxs)
        if filter_masks{s}(m) == 1
            new_all_maxs(end+1) = spectra{s}.all_maxs(m);
            new_all_mins(end+1,:) = spectra{s}.all_mins(m,:);
        end
    end
    spectra{s}.all_maxs = new_all_maxs;
    spectra{s}.all_mins = new_all_mins;
end
fprintf('Number of filtered peaks: %d\n',num_filtered);

% % Filter the peaks based on observed max height
% [vs,sorted_inxs] = sort(observed_peaks_min_height,'ascend');
% last_x = 0;
% last_xs = [];
% h = figure;
% for i = 1:length(sorted_inxs)
%     observed_peak = observed_peaks{sorted_inxs(i)};
%     inxs = last_x+(1:length(observed_peak));
%     if mod(i-1,2) == 0
%         line(inxs,observed_peak-min(observed_peak),'Color','b');
%     else
%         line(inxs,observed_peak-min(observed_peak),'Color','k');
%     end
%     last_x = inxs(end);
%     last_xs(end+1) = last_x;
% end
% 
% preview_h = -1;
% threshold = 0;
% while true
%     threshold = input('Enter a threshold, leave blank for a preview, or type g to use graph to define threshold: ','s');
%     if strcmp(threshold,'') || ~isempty(regexp(threshold,'^\s*$')) % Preview
%         if preview_h ~= -1
%             close(preview_h);
%         end
%         ax = get(h,'CurrentAxes');
%         xl = get(ax,'xlim');
%         loc = xl(1);
%         inxs = find(last_xs >= ceil(loc)); % Find all
%         threshold = vs(inxs(1));
%         preview_h = figure;
%         hold on
%         nm = size(Y);
%         for s = 1:nm(2)
%             plot(x,Y(:,s),'k');
%         end
%         for i = 1:(inxs(1)-1) % Removed
%             plot(observed_peaks_x{sorted_inxs(i)},observed_peaks{sorted_inxs(i)},'r');
%         end
%         for i = inxs % Kept
%             plot(observed_peaks_x{sorted_inxs(i)},observed_peaks{sorted_inxs(i)},'g');
%         end
%         hold off
%         preview_ax = get(preview_h,'CurrentAxes');
%         set(preview_ax,'xdir','reverse');
%     elseif ~isempty(regexp(threshold,'^\s*g\s*$')) % From graph
%         ax = get(h,'CurrentAxes');
%         xl = get(ax,'xlim');
%         loc = xl(1);
%         close(h);
%         inx = find(last_xs >= ceil(loc),1,'first');
%         threshold = vs(inx);
%         break;
%     else
%         threshold = str2num(threshold);
%         close(h);
%         break;
%     end
% end
% fprintf('Observed minimum height threshold: %f\n',threshold);
% for s = 1:num_samples
%     new_all_maxs = [];
%     new_all_mins = [];
%     for m = 1:length(spectra{s}.all_maxs)
%         max_inx = spectra{s}.all_maxs(m);
%         min_inxs = spectra{s}.all_mins(m,:);
%         height1 = Y(max_inx,s) - Y(min_inxs(1),s);
%         height2 = Y(max_inx,s) - Y(min_inxs(end),s);
%         if height1 >= threshold || height2 >= threshold
%             new_all_maxs(end+1) = spectra{s}.all_maxs(m);
%             new_all_mins(end+1,:) = spectra{s}.all_mins(m,:);
%         end
%     end
%     spectra{s}.all_maxs = new_all_maxs;
%     spectra{s}.all_mins = new_all_mins;
% end