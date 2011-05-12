function [bins,stats,final_score] = perform_heuristic_bin_dynamic(x,max_spectrum,spectra,max_dist_btw_maxs,min_dist_from_boundary,multiplet_R2_cutoff,max_dist_btw_multiplet_peaks)
global maxs_spectra
%global max_dist_btw_maxs min_dist_from_boundary

xres = abs(x(1)-x(2));
max_dist_between_multiplet_peaks = round(max_dist_btw_multiplet_peaks/xres);

%% Grab the unique maxs
ht = java.util.Hashtable();
unique_maxs = [];
for s = 1:length(spectra)
    for i = 1:length(spectra{s}.maxs)
        if ~ht.containsKey(spectra{s}.maxs(i))
            ht.put(spectra{s}.maxs(i),spectra{s}.maxs(i));
            unique_maxs(end+1) = spectra{s}.maxs(i);
        end
    end
end
unique_maxs = sort(unique_maxs,'ascend');

%% Go through the peaks and look for multiplets
multiplet_list = {};
for s = 1:length(spectra)
    for i = 1:length(spectra{s}.maxs)
        % Look for doublets
        if i < length(spectra{s}.maxs)
            max_inx1 = spectra{s}.maxs(i);
            min_inxs1 = spectra{s}.mins(i,:);
            num_inxs1 = abs(min_inxs1(1) - min_inxs1(2));
            max_inx2 = spectra{s}.maxs(i+1);
            min_inxs2 = spectra{s}.mins(i+1,:);
            num_inxs2 = abs(min_inxs2(1) - min_inxs2(2));            
            inxs1 = min_inxs1(1):min_inxs1(2);
            inxs2 = min_inxs2(1):min_inxs2(2);
            inxs1 = inxs1(min([num_inxs1,num_inxs2]):-1:1);
            inxs2 = inxs2(1:min([num_inxs1,num_inxs2]));
            num_inxs_btw_maxs = abs(max_inx1 - max_inx2);
            R2 = calc_R2(spectra{s}.y_smoothed(inxs1),spectra{s}.y_smoothed(inxs2));
            if R2 >= multiplet_R2_cutoff && num_inxs_btw_maxs <= max_dist_between_multiplet_peaks
                multiplet_list{end+1} = [max_inx1,max_inx2];
            end
        end
    end
end

%% Assign each maximum to an index. This is important for future
% calculations
maxs_spectra = cell(1,length(x)); % All of the spectra that have a max at unique_maxs
for s = 1:length(spectra)
    for i = 1:length(spectra{s}.maxs)
        ix = ht.get(spectra{s}.maxs(i));
        maxs_spectra{ix}(end+1) = s;
    end
end

%% Group maxs together that are less than min_dist_btw_maxs apart
grouped_maxs = [];
i = 1;
while i <= length(unique_maxs)
    grouped_maxs(end+1,:) = [unique_maxs(i),unique_maxs(i)];
    j = i+1;
    while j <= length(unique_maxs) && abs(grouped_maxs(end,2)-unique_maxs(j)) < 2*min_dist_from_boundary
        grouped_maxs(end,2) = unique_maxs(j);
        j = j + 1;
    end
    i = j;
end

%% Now combine groups if they are part of multiplets
g = 1;
while g < length(grouped_maxs)
    inxs1 = grouped_maxs(g,:);
    inxs2 = grouped_maxs(g+1,:);
    combine = false;
    for i = 1:length(multiplet_list)
        combine = false;
        if min(multiplet_list{i}) <= inxs1(2) && inxs1(2) <= max(multiplet_list{i}) && ...
            min(multiplet_list{i}) <= inxs2(1) && inxs2(1) <= max(multiplet_list{i})
            combine = true;
            break;
        end
    end
    if combine
        grouped_maxs(g,2) = grouped_maxs(g+1,2);
        grouped_maxs = [grouped_maxs(1:g,:);grouped_maxs(g+2:end,:)];
    else
        g = g + 1;
    end
end

% % plot the grouped maxs
% [r,c] = size(grouped_maxs);
% temp_handles = [];
% for i = 1:r
%     if grouped_maxs(i,1) ~= grouped_maxs(i,2)
%         temp_handles(end+1) = line([x(grouped_maxs(i,1)),x(grouped_maxs(i,1))],[min(max_spectrum),max(max_spectrum)],'Color','g');
%         temp_handles(end+1) = line([x(grouped_maxs(i,2)),x(grouped_maxs(i,2))],[min(max_spectrum),max(max_spectrum)],'Color','r');
%     else
%         temp_handles(end+1) = line([x(grouped_maxs(i,1)),x(grouped_maxs(i,1))],[min(max_spectrum),max(max_spectrum)],'Color','b');
%     end
% end
% delete(temp_handles);
[bins,final_score,stats] = align_segment(grouped_maxs,max_dist_btw_maxs);

bins = finalize_bins(x,max_spectrum,bins,max_dist_btw_maxs,min_dist_from_boundary);

% function dist = dist_from_boundary(composite_spectrum,unique_max_i,unique_max_j)
% left_inx = unique_max_i;
% right_inx = unique_max_j;
% inxs = (left_inx+1):(right_inx-1);
% if isempty(inxs)
%     dist = 0;
%     return;
% end
% [v,ix] = min(composite_spectrum(inxs));
% dist_i = abs(inxs(ix)-unique_max_i);
% dist_j = abs(inxs(ix)-unique_max_j);
% dist = min([dist_i,dist_j]);

function R2 = calc_R2(y1,y2)
SSreg = sum((y1-y2).^2);
SStot = sum((y2 - mean(y2)).^2);
R2 = 1 - SSreg/SStot;