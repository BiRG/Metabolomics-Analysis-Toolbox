function results = reducer(x,y,stdin,prev_BETA,prev_x_maxs,options)
if ~exist('options')
    options = {};
    options.baseline_width = 0.01;    
    options.max_width = 70;
    options.num_generations = 100;
end
data = process_stdin_mapper(stdin);
if ~isempty(prev_BETA)    
    peaks_to_add = [];
    for i = 1:length(prev_x_maxs)
        found = false;
        for k = 1:length(data)
            if strcmp(num2str(data{k}.key),num2str(prev_x_maxs(i)))
                found = true;
                break;
            end
        end
        if ~found
            peaks_to_add(end+1) = i;
        end
    end
    for j = 1:length(peaks_to_add)
        i = peaks_to_add(j);
        data{end+1} = data{end}; % Make copy first
        data{end}.key = prev_x_maxs(i);
        for z = 1:length(data{end}.BETAs)
            data{end}.BETAs{z} = prev_BETA(4*(i-1)+(1:4));
        end
    end
end

% target_number = 3;
% for i = 1:length(data)
%     if length(data{i}.BETAs) ~= target_number
%         data{i}
%     end
% end

% noise_std = std(y(1:30)); % Use first 30 points
xwidth = x(1)-x(2);
baseline_width_inx = round(options.baseline_width/xwidth);
x_baseline_BETA = x(1:baseline_width_inx:end);
if x_baseline_BETA ~= x(end)
    x_baseline_BETA(end+1) = x(end);
end
baseline_BETA = 0*x_baseline_BETA;

num_peaks = length(data);
keys = zeros(1,num_peaks);
for k = 1:length(data)
    keys(k) = data{k}.key;
end
[sorted_keys,sorted_key_inxs] = sort(keys,'descend');
num_iterations = length(data{1}.BETAs);

% Precompute peaks
peaks = cell(length(data{1}.BETAs),length(keys));
peak_locs = zeros(1,length(keys));
for k = 1:length(sorted_key_inxs)
    inx = sorted_key_inxs(k);
    peak_locs(k) = sorted_keys(k);
    for p = 1:length(data{inx}.BETAs);
        peaks{p,k} = one_peak_model(data{inx}.BETAs{p},x);
    end
end

% Initialize a random solution
solution = {};
solution.pinxs = zeros(1,num_peaks);
for k = 1:num_peaks
    solution.pinxs(k) = randi([1,num_iterations]);
end

%% Construct initial y_peaks
for k = 1:length(solution.pinxs)
    if k == 1
        y_peaks = peaks{solution.pinxs(k),k};
    elseif ~isempty(peaks{solution.pinxs(k),k}) % Sometimes there is a failure
        y_peaks = y_peaks + peaks{solution.pinxs(k),k};
    end
end

%% Construct baseline matrices
lambda = 20;
xwidth = x(1)-x(2);
inxs = round((x(1) - x_baseline_BETA)/xwidth) + 1;
     
% Weights (0 = ignore this intensity)
w = zeros(size(y));
w(inxs) = 1;
% Matrix version of W
W = sparse(length(y),length(y));
for i = 1:length(w)
    W(i,i) = w(i);
end
% Difference matrix (they call it derivative matrix, which a little
% misleading)
D = sparse(length(y),length(y));
for i = 1:length(y)-1
    D(i,i) = 1;
    D(i,i+1) = -1;
end

A = W + lambda*D'*D;

%% Construct a special y for the fitness function, where the zero regions
%% are interpolated
xs = [];
ys = [];
xi = [];
inxs = [];
y_for_fitness = y;
for i = 2:length(y) % assume first is not zero
    if y(i) == 0
        xi(end+1) = x(i);
        inxs(end+1) = i;
        if isempty(xs)
            xs(end+1) = x(i-1);
            ys(end+1) = y(i-1);
        end
    elseif ~isempty(xi)
        xs(end+1) = x(i);
        ys(end+1) = y(i);
        y_for_fitness(inxs) = interp1(xs,ys,xi,'linear');
        xi = [];
        inxs = [];
        ys = [];
        xs = [];
    end
end

[solution,y_baseline] = fitness(solution,y_for_fitness,y_peaks,A,W);

%% Define the regions
i = 1;
regions = {};
r = 1;
while (i <= length(x))
    width = options.max_width;
    last = i+width;
    if (last >= length(x))
        last = length(x);
    end

    regions{r} = {};
    regions{r}.peak_inxs = find(x(i) >= peak_locs & peak_locs >= x(last));

    i = last + 1;
    r = r + 1;
end

%% Now optimize two regions at a time, keeping the region on the left
for r = 1:length(regions)-1    
    peak_inxs = [regions{r}.peak_inxs,regions{r+1}.peak_inxs];
    prev_num_changed = NaN;
%     fprintf('Region %d/%d\n',r,length(regions));
    if ~isempty(peak_inxs)
        for g = 1:options.num_generations
%             fprintf('Generation %d\n',g);
            order_inxs = randperm(length(peak_inxs)); % Randomly pick the order to change the peaks
            num_changed = 0;
            for i = 1:length(order_inxs)
                k = peak_inxs(order_inxs(i));
                scores = zeros(1,num_iterations);
                temps = cell(1,num_iterations);
                for j = 1:num_iterations
                    temp = solution;
                    if temp.pinxs(k) ~= j % Don't need to check
                        temp.pinxs(k) = j;
                        y_peaks = y_peaks - peaks{solution.pinxs(k),k}; % Remove previous
                        y_peaks = y_peaks + peaks{temp.pinxs(k),k}; % Add new peak
                        [temp,y_baseline] = fitness(temp,y_for_fitness,y_peaks,A,W);
                        y_peaks = y_peaks - peaks{temp.pinxs(k),k}; % Remove new peak
                        y_peaks = y_peaks + peaks{solution.pinxs(k),k}; % Add previous back
                    end
                    scores(j) = temp.r2;
                    temps{j} = temp;
                end
                [v,ix] = max(scores);
                if ix ~= solution.pinxs(k) % New solution
                    solution = temps{ix};
                    num_changed = num_changed + 1;
                end
            end
            %[solution,baseline_BETA,y_baseline] = fitness(solution,x,y,y_baseline,x_baseline_BETA,baseline_BETA,baseline_lb,baseline_ub);
%             fprintf('r2: %.4f, # changed: %d\n',solution.r2,num_changed);
            if num_changed == 0 && prev_num_changed == 0
                break;
            else
                prev_num_changed = num_changed;
            end
        end 
    end
end


% % Evolve the best solution up to a maximum number of generations or until
% % we stop changing
% prev_num_changed = NaN;
% for g = 1:options.num_generations
%     order_inxs = randperm(num_peaks); % Randomly pick the order to change the peaks
%     num_changed = 0;
%     for i = 1:length(order_inxs)
%         k = order_inxs(i);
%         scores = zeros(1,num_iterations);
%         temps = cell(1,num_iterations);
%         for j = 1:num_iterations
%             temp = solution;
%             temp.pinxs(k) = j;
%             [temp,baseline_BETA,y_baseline] = fitness(temp,x,y,x_baseline_BETA,baseline_BETA);
%             scores(j) = temp.r2;
%             temps{j} = temp;
%         end
%         [v,ix] = max(scores);
%         if ix ~= solution.pinxs(k) % New solution
%             solution = temps{ix};
%             num_changed = num_changed + 1;
%         end
%     end
%     %[solution,baseline_BETA,y_baseline] = fitness(solution,x,y,y_baseline,x_baseline_BETA,baseline_BETA,baseline_lb,baseline_ub);
%     fprintf('r2: %.4f, # changed: %d\n',solution.r2,num_changed);
%     if num_changed == 0 && prev_num_changed == 0
%         break;
%     else
%         prev_num_changed = num_changed;
%     end
% end

results = {};
results.solution = solution;
BETA = [];
for k = 1:length(sorted_key_inxs)
    inx = sorted_key_inxs(k);
% for inx = 1:length(data)
    BETA = [BETA;data{inx}.BETAs{solution.pinxs(inx)}];
end
results.BETA = BETA;
results.x_baseline_BETA = x_baseline_BETA;
% results.baseline_BETA = baseline_BETA;
results.y_baseline = y_baseline;

fprintf('r2: %.4f\n',solution.r2);

% plot(x,y,x,solution.y_fit,x,solution.y_peaks,x,y_baseline);
% set(gca,'xdir','reverse');
% legend('Exp','Fit','Peaks','Baseline');