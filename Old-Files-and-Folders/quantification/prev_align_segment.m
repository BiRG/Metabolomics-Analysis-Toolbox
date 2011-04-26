function [bins,final_score,stats] = align_segment(grouped_maxs,max_distance)
global num_bin_scores_calculated
% global x max_spectrum max_dist_btw_maxs min_dist_from_boundary
% lines = [];
num_bin_scores_calculated = 0;
align_scores = Inf*ones(1,rows(grouped_maxs)+1);
align_tscores = Inf*ones(1,rows(grouped_maxs)+1);
align_directions = NaN*ones(1,rows(grouped_maxs)+1); % i(col inx):two or more peaks, -1:own bin

% Fill out the first entry
align_scores(1) = 0; %score(answer_peaks{1},calc_peaks{1});
align_tscores(1) = 0; %score(answer_peaks{1},calc_peaks{1});
align_directions(1) = NaN;

% Fill in the rest
for j = 2:rows(grouped_maxs)+1
%     if x(grouped_maxs(j-1,1)) < 8.955
%         disp('here');
%     end
    % Always have a score for being in its own bin
    [score,tscore] = bin_score(grouped_maxs(j-1,1),grouped_maxs(j-1,2));
    ind_score = align_scores(j-1) + score;
    ind_tscore = align_tscores(j-1) + tscore;
%     ind_tscore = tscore;
    
    min_match_score = Inf;
    min_match_j = 0;
    max_match_tscore = -Inf;
    for match_j = (j-1):-1:2
        % Could also include a cutoff on the number of maximum because the
        % score would not increase...
        if abs(grouped_maxs(j-1,2) - grouped_maxs(match_j-1,1)) <= max_distance
            [score,tscore] = bin_score(grouped_maxs(match_j-1,1),grouped_maxs(j-1,2));
            match_score = align_scores(match_j-1) + score;
            match_tscore = align_tscores(match_j-1) + tscore;
%             match_tscore = tscore;
            if match_score < min_match_score
                min_match_j = match_j;
                min_match_score = match_score;
                max_match_tscore = match_tscore;
            elseif match_score == min_match_score && match_tscore > max_match_tscore
                min_match_j = match_j;
                min_match_score = match_score;
                max_match_tscore = match_tscore;
            end
        else
            break;
        end
    end
    if min_match_score < ind_score
        align_scores(j) = min_match_score;
        align_tscores(j) = max_match_tscore;
        align_directions(j) = min_match_j;
    elseif min_match_score == ind_score && max_match_tscore > ind_tscore
        align_scores(j) = min_match_score;
        align_tscores(j) = max_match_tscore;
        align_directions(j) = min_match_j;
    else
        align_scores(j) = ind_score;
        align_tscores(j) = ind_tscore;
        align_directions(j) = -1;
    end

%     % Just for debugging purposes
%     for l = 1:length(lines)
%         delete(lines(l));
%     end
%     inxs = find(~isnan(align_directions));
%     temp_bins = create_temp_bins(grouped_maxs(inxs-1,:),align_directions([1,inxs]));
% 
%     bins = [];
%     for i = rows(temp_bins):-1:1
%         if temp_bins(i,1) ~= 0 && temp_bins(i,2) ~= 0
%             bins(end+1,:) = [0,0];
%             if temp_bins(i,1) ~= 1
%                 bins(end,1) = grouped_maxs(temp_bins(i,1),1)+1;
%             else
%                 bins(end,1) = grouped_maxs(temp_bins(i,1),1);
%             end
%             bins(end,2) = grouped_maxs(temp_bins(i,2),2);
%         elseif temp_bins(i,1) == 0 && temp_bins(i,2) ~= 0
%             bins(end+1,1) = grouped_maxs(temp_bins(i,2),1);
%             bins(end,2) = grouped_maxs(temp_bins(i,2),2);
%         elseif temp_bins(i,1) ~= 0 && temp_bins(i,2) == 0
%             bins(end+1,1) = grouped_maxs(temp_bins(i,1),1);
%             bins(end,2) = grouped_maxs(temp_bins(i,1),2);
%         end
%     end
%     bins = finalize_bins(x,max_spectrum,bins,max_dist_btw_maxs,min_dist_from_boundary);
%     lines = [];
%     for b = 1:rows(bins)
%         %lines(end+1) = line([bins(b,1),bins(b,1)],[-5,max(max_spectrum)],'Color','r');
%         lines(end+1) = line([bins(b,2),bins(b,2)],[-5,max(max_spectrum)],'Color','r');
%     end
end

temp_bins = create_temp_bins(grouped_maxs,align_directions);

bins = [];
for i = length(temp_bins):-1:1
    if temp_bins(i,1) ~= 0 && temp_bins(i,2) ~= 0
        bins(end+1,:) = [0,0];
        if temp_bins(i,1) ~= 1
            bins(end,1) = grouped_maxs(temp_bins(i,1),1)+1;
        else
            bins(end,1) = grouped_maxs(temp_bins(i,1),1);
        end
        bins(end,2) = grouped_maxs(temp_bins(i,2),2);
    elseif temp_bins(i,1) == 0 && temp_bins(i,2) ~= 0
        bins(end+1,1) = grouped_maxs(temp_bins(i,2),1);
        bins(end,2) = grouped_maxs(temp_bins(i,2),2);
    elseif temp_bins(i,1) ~= 0 && temp_bins(i,2) == 0
        bins(end+1,1) = grouped_maxs(temp_bins(i,1),1);
        bins(end,2) = grouped_maxs(temp_bins(i,1),2);
    end
end
final_score = align_scores(end,end);

% Return the stats
stats = {};
stats.num_bin_scores_calculated = num_bin_scores_calculated;

function [sc,tsc] = bin_score(left_inx,right_inx)
global nSpectra maxs_spectra num_bin_scores_calculated spectra
norm_num_maxs_in_bin = zeros(1,nSpectra);

num_bin_scores_calculated = num_bin_scores_calculated + 1;

% Find the distance to from the left most max to the previous max
% and the distance from the right most max to the next max
dist_to_prev_max = NaN;
dist_to_next_max = NaN;
bin_left_inx = NaN;
bin_right_inx = NaN;

for i = left_inx:right_inx
    norm_num_maxs_in_bin(maxs_spectra{i}) = norm_num_maxs_in_bin(maxs_spectra{i}) + 1;
    for j = 1:length(maxs_spectra{i})
        if isnan(dist_to_prev_max)
            for k = i-1:-1:1
                if ~isempty(maxs_spectra{k})
                    dist_to_prev_max = i - k;
                    bin_left_inx = k;
                    break;
                end
            end
        end
        % A few extra computations here, but not much
        for k = i+1:length(maxs_spectra)
            if ~isempty(maxs_spectra{k})
                dist_to_next_max = k - i;
                bin_right_inx = k;
                break;
            end
        end
    end
end
if ~isnan(dist_to_next_max) && ~isnan(dist_to_prev_max)
    sum_corrs = 0;
    for s = 2:length(spectra)
        sum_corrs = sum_corrs + corr(spectra{s}.y_smoothed(bin_left_inx:bin_right_inx),...
            spectra{1}.y_smoothed(bin_left_inx:bin_right_inx));
    end
    tsc = sum_corrs/(length(spectra)-1);
else
    tsc = NaN;
end
% if isnan(dist_to_next_max) && isnan(dist_to_prev_max)
%     tsc = NaN;
% else
%     tsc = 0;
%     n = 0;
%     if ~isnan(dist_to_next_max)
%         tsc = tsc + dist_to_next_max;
%         n = n + 1;
%     end
%     if ~isnan(dist_to_prev_max)
%         tsc = tsc + dist_to_prev_max;
%         n = n + 1;
%     end
%     tsc = tsc/n;
% end
norm_num_maxs_in_bin = abs(1 - norm_num_maxs_in_bin);

sc = 0;
weights = [1.0];
for s = 1:nSpectra
    values = [norm_num_maxs_in_bin(s)];
    sc = sc + weights*values';
end

function n = rows(mt)
nm = size(mt);
n = nm(1);