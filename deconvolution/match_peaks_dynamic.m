function [match_ids,final_score] = match_peaks_dynamic(answer_maxs,calc_maxs,max_distance)
answer_inxs = 1:length(answer_maxs);
calc_inxs = 1:length(calc_maxs);
align_scores = Inf*ones(length(answer_maxs)+1,length(calc_maxs)+1);
align_directions = NaN*ones(length(answer_maxs)+1,length(calc_maxs)+1); % -1:left, 0:match, 1:up

% Fill out the first row and first column
align_scores(1,1) = 0; %score(answer_peaks{1},calc_peaks{1});
align_directions(1,1) = NaN;
i = 1;
for j = 2:length(calc_maxs)+1
    align_scores(i,j) = align_scores(i,j-1) + score([],calc_maxs(j-1),max_distance);
    align_directions(i,j) = -1;
end
j = 1;
for i = 2:length(answer_maxs)+1
    align_scores(i,j) = align_scores(i-1,j) + score(answer_maxs(i-1),[],max_distance);
    align_directions(i,j) = 1;
end

% Fill in the rest
for i = 2:length(answer_maxs)+1
    for j = 2:length(calc_maxs)+1
        up_score = align_scores(i-1,j) + score(answer_maxs(i-1),[],max_distance);
        left_score = align_scores(i,j-1) + score([],calc_maxs(j-1),max_distance);
        match_score = Inf;
        if abs(answer_maxs(i-1) - calc_maxs(j-1)) <= max_distance
            match_score = align_scores(i-1,j-1) + score(answer_maxs(i-1),calc_maxs(j-1),max_distance);
        end
        if match_score <= up_score && match_score <= left_score
            align_scores(i,j) = match_score;
            align_directions(i,j) = 0;
        elseif up_score <= match_score && up_score <= left_score
            align_scores(i,j) = up_score;
            align_directions(i,j) = 1;
        elseif left_score <= match_score && left_score <= up_score
            align_scores(i,j) = left_score;
            align_directions(i,j) = -1;
        end
    end
end

match_ids = {};
i = length(answer_maxs)+1;
j = length(calc_maxs)+1;
while true
    if align_directions(i,j) == 0 % Match
        match_ids{end+1} = [i-1,j-1];
        i = i - 1;
        j = j - 1;
    elseif align_directions(i,j) == -1 % Left
        match_ids{end+1} = [0,j-1];
        j = j - 1;
    elseif align_directions(i,j) == 1 % Up
        match_ids{end+1} = [i-1,0];
        i = i - 1;
    end
    
    if i == 1 && j == 1
        break;
    end
end
temp_match_ids = match_ids;

match_ids = {};
for i = length(temp_match_ids):-1:1
    match_ids{end+1} = [0,0];
    if temp_match_ids{i}(1) ~= 0
        match_ids{end}(1) = answer_inxs(temp_match_ids{i}(1));
    end
    if temp_match_ids{i}(2) ~= 0
        match_ids{end}(2) = calc_inxs(temp_match_ids{i}(2));
    end
end
final_score = align_scores(end,end);

function sc = score(x1,x2,max_distance)
if ~isempty(x1) && ~isempty(x2)
    sc = abs(x1-x2);
elseif isempty(x1)
    sc = max_distance;
else
    sc = max_distance;
end

