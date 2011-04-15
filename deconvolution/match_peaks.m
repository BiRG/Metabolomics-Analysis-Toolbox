function [final_match_ids,final_score] = match_peaks(left,right,xwidth,answer_maxs,calc_maxs)
if isempty(calc_maxs) || isempty(answer_maxs)
    final_match_ids = {};
    final_score = NaN;
    return;
end
    
offsets = [(left - calc_maxs(end)):-xwidth:(right-calc_maxs(1)),0]; % Make sure we try 0 as well
scores = zeros(size(offsets));
match_ids = cell(size(offsets));
for i = 1:length(offsets)
    offset = offsets(i);
    [scores(i),match_ids{i}] = score(answer_maxs,calc_maxs,offset);
end
[final_score,inx] = min(scores);
final_match_ids = match_ids{inx};

function [sc,match_ids] = score(answer_maxs,calc_maxs,offset)
calc_maxs = calc_maxs + offset;
diff_matrix = NaN*ones(length(answer_maxs),length(calc_maxs));
for i = 1:length(answer_maxs)
    for j = i:length(calc_maxs)
        diff_matrix(i,j) = abs(answer_maxs(i)-calc_maxs(j));
    end
end

sc = 0;
match_ids = {};
while (true)
    [s_v s_i] = min(diff_matrix(:));
    if isnan(s_v)
        return;
    end
    sc = sc + s_v;
    [r c] = ind2sub(size(diff_matrix),s_i);
    match_ids{end+1} = [r c];
    % Can't use either of these again
    diff_matrix(r,:) = NaN;
    diff_matrix(:,c) = NaN;
end
