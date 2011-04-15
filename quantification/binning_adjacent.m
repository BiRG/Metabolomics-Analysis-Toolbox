function [adj_saved_data,all_match_inxs] = binning_adjacent(main_h,left,right,far_left,far_right,adj_saved_data)
reference = getappdata(main_h,'reference');
if isempty(reference)
    questdlg('Load or set a reference','ERROR','OK', 'OK');
    set_reference_error
end
collections = getappdata(main_h,'collections');

for i = 1:length(collections)
    fprintf('Starting collection %d\n',i);
    for j = 1:collections{i}.num_samples
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

        [y_fit,fit_inxs,MGPX,baseline_BETA,x_baseline_BETA,xmaxs,converged] = curve_fit_helper(collections,i,j,left,right,far_left_min,far_right_min);
        collections{i}.spectra{j}.xmaxs = xmaxs;
        setappdata(main_h,'collections',collections);
        X = MGPX(4:4:end);
        y_residual = collections{i}.Y(:,j) - y_fit;

        % Individual peaks
        peaks = {};
        for k = 1:length(X)
            MGPX_o = MGPX(4*(k-1)+(1:4));
            model = @(PARAMS,x_) (global_model(PARAMS,x_,1,x_baseline_BETA)); 
            peaks{k} = model([MGPX_o,0*x_baseline_BETA],collections{i}.x(inxs)');
        end

        % Just the baseline
        model = @(PARAMS,x_) (global_model(PARAMS,x_,0,x_baseline_BETA));
        y_baseline = model(baseline_BETA,collections{i}.x(inxs)');

        if j == 1 % Initialize
            adj_saved_data{i}.Y_residual = {};
            adj_saved_data{i}.Y_fit = {};
            adj_saved_data{i}.Y_baseline = {};
            adj_saved_data{i}.peaks = {};
            adj_saved_data{i}.X = {};
            adj_saved_data{i}.x = {};
            adj_saved_data{i}.converged = {};
        end
        adj_saved_data{i}.Y_baseline{j} = y_baseline;
        adj_saved_data{i}.peaks{j} = peaks;
        adj_saved_data{i}.Y_residual{j} = y_residual(inxs);
        adj_saved_data{i}.Y_fit{j} = y_fit(inxs);
        adj_saved_data{i}.X{j} = X;
        adj_saved_data{i}.x{j} = collections{i}.x(inxs);
        adj_saved_data{i}.converged{j} = converged;
    end
    fprintf('Finishing collection %d\n',i);
end

% Now perform the matching, so we can quantify the data
inxs = find(left >= reference.x & reference.x >= right);
% collections{1}.freeze = true; % Mark reference as frozen
y_reference = reference.y(inxs);
inxs = find(left >= reference.X & reference.X >= right);
X_reference = reference.X(inxs);
tot = 0;
for i = 1:length(collections)
    inxs = find(left >= collections{i}.x & collections{i}.x >= right);
    for j = 1:collections{i}.num_samples
        tot = tot + 1;
        % Try all of the different alignments
        y = collections{i}.Y(inxs,j);
        best_s = NaN;
        best_rho = NaN;
        best_y_shifted = zeros(size(y));
        for s = -(length(y)-1):(length(y)-1)
            y_shifted = y;
            if s > 0
                y_shifted((end-s+1):end) = y_shifted(end-s);
            elseif s < 0
                y_shifted(1:(end-(length(y)+s))) = y_shifted(-s+1);
            end
            y_shifted = circshift(y_shifted,s);
%             y_shifted = y_shifted(inxs);
            mn = min([length(y_shifted),length(y_reference)]);
            rho = pearson(y_shifted(1:mn),y_reference(1:mn));
            if isnan(best_rho) || rho >= best_rho
                best_s = s;
                best_rho = rho;
                best_y_shifted = y_shifted;
            end
        end
        xwidth = abs(collections{i}.x(1)-collections{i}.x(2));
        if ~isfield(adj_saved_data{i},'xshift')
            adj_saved_data{i}.xshift = {};
            adj_saved_data{i}.bin_X_aligned = {};
            adj_saved_data{i}.bin_X = {};
            adj_saved_data{i}.translate_inxs = {};
            adj_saved_data{i}.match_inxs = {};
        end
        adj_saved_data{i}.xshift{j} = xwidth*best_s;
        finxs = find(left >= adj_saved_data{i}.X{j} & adj_saved_data{i}.X{j} >= right);
        adj_saved_data{i}.translate_inxs{j} = finxs;
        adj_saved_data{i}.bin_X{j} = adj_saved_data{i}.X{j}(finxs);
        adj_saved_data{i}.bin_X_aligned{j} = adj_saved_data{i}.bin_X{j} - xwidth*best_s;
        adj_saved_data{i}.match_inxs{j} = {};
%         adj_saved_data{i}.match_inxs{j} = match_peaks(X_reference,adj_saved_data{i}.bin_X_aligned{j});
        adj_saved_data{i}.match_inxs{j} = align_segment(X_reference,adj_saved_data{i}.bin_X_aligned{j},max(collections{i}.x)-min(collections{i}.x));
    end
end
match_inxs = zeros(tot,length(X_reference));
cnt = 1;
for i = 1:length(collections)
    for j = 1:collections{i}.num_samples
        for m = 1:length(adj_saved_data{i}.match_inxs{j})
            if adj_saved_data{i}.match_inxs{j}{m}(1) ~= 0 && adj_saved_data{i}.match_inxs{j}{m}(2) ~= 0
                rix = adj_saved_data{i}.match_inxs{j}{m}(1);
                mix = adj_saved_data{i}.match_inxs{j}{m}(2);
                if left >= X_reference(rix) && X_reference(rix) >= right && left >= adj_saved_data{i}.bin_X{j}(mix) && adj_saved_data{i}.bin_X{j}(mix) >= right
                    match_inxs(cnt,rix) = mix;
                end
            end
        end
        cnt = cnt + 1;
    end
end
all_match_inxs = match_inxs;
setappdata(main_h,'reference',reference);
cnt = 1;
for i = 1:length(collections)
    for j = 1:collections{i}.num_samples
        if j == 1
            adj_saved_data{i}.bin_values = {};
            adj_saved_data{i}.bin_locations = {};
        end
        adj_saved_data{i}.bin_values{j} = [];
        adj_saved_data{i}.bin_locations{j} = [];
        nm = size(match_inxs);
        mcnt = 1;
        for m = 1:nm(2)
            if sum(match_inxs(:,m) > 0) == nm(1) % Match across all samples
                jix = adj_saved_data{i}.translate_inxs{j}(match_inxs(cnt,m));
                adj_saved_data{i}.bin_values{j}(end+1) = sum(adj_saved_data{i}.peaks{j}{jix});
                adj_saved_data{i}.bin_locations{j}(end+1) = X_reference(m);
                mcnt = mcnt + 1;
            end
        end
        cnt = cnt + 1;
    end
end

setappdata(main_h,'collections',collections);

function result_match_inxs = match_peaks(answer_maxs,calc_maxs)
result_match_inxs = {};
match_inxs = [];
dists = [];
for i = 1:length(answer_maxs)
    for j = 1:length(calc_maxs)
        match_inxs(end+1,:) = [i,j];
        dists(end+1) = abs(answer_maxs(i)-calc_maxs(j));
    end
end
[sorted_dists,inxs] = sort(dists,'ascend');
for d = 1:length(sorted_dists)
    a = match_inxs(inxs(d),:);
    i = a(1);
    j = a(2);
    if answer_maxs(i) == 0 || calc_maxs(j) == 0 % One or both already used
        continue;
    end
    if answer_maxs(i) > calc_maxs(j)
        lt = answer_maxs(i);
        gt = calc_maxs(j);
    else
        gt = answer_maxs(i);
        lt = calc_maxs(j);
    end
    if ~isempty(answer_maxs(find(lt > answer_maxs & answer_maxs > gt)) == 0) % Can't skip
        continue;
    end
    if ~isempty(calc_maxs(find(lt > calc_maxs & calc_maxs > gt)) == 0) % Can't skip
        continue;
    end
    answer_maxs(i) = 0;
    calc_maxs(j) = 0;
    result_match_inxs{end+1} = [i,j];
end

function r = pearson(x,y)
z = x + y;
inxs = find(~isnan(z));
x = x(inxs);
y = y(inxs);
r = sum((x-mean(x)).*(y-mean(y)))/((length(x)-1)*std(x)*std(y));

function [match_inxs,final_score] = align_segment(answer_maxs,calc_maxs,max_distance)
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

match_inxs = {};
i = length(answer_maxs)+1;
j = length(calc_maxs)+1;
while true
    if align_directions(i,j) == 0 % Match
        match_inxs{end+1} = [i-1,j-1];
        i = i - 1;
        j = j - 1;
    elseif align_directions(i,j) == -1 % Left
        match_inxs{end+1} = [0,j-1];
        j = j - 1;
    elseif align_directions(i,j) == 1 % Up
        match_inxs{end+1} = [i-1,0];
        i = i - 1;
    end
    
    if i == 1 && j == 1
        break;
    end
end
temp_match_inxs = match_inxs;

match_inxs = {};
for i = length(temp_match_inxs):-1:1
    match_inxs{end+1} = [0,0];
    if temp_match_inxs{i}(1) ~= 0
        match_inxs{end}(1) = answer_inxs(temp_match_inxs{i}(1));
    end
    if temp_match_inxs{i}(2) ~= 0
        match_inxs{end}(2) = calc_inxs(temp_match_inxs{i}(2));
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