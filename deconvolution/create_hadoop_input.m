function output = create_hadoop_input(x,y,all_maxs,all_mins,outfile,options)
% x (d x 1) and y (d x 1)
% e.g., outfile = 'hadoop_output.txt'
if ~exist('options')
    options = {};
    options.min_width = 30;
    options.max_width = 70;
    options.num_iterations = 3;
end
if ~isempty(outfile)
    fid = fopen(outfile,'w');
end
output = '';

% Construct a special y for the optimization, where the zero regions
% are interpolated
xs = [];
ys = [];
xi = [];
inxs = [];
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
        y(inxs) = interp1(xs,ys,xi,'linear');
        xi = [];
        inxs = [];
        ys = [];
        xs = [];
    end
end

mins = all_mins;
biggest_gap = max(abs(mins(:,1)-mins(:,2)));
mins = mins(:,1);
for iter = 1:options.num_iterations
    i = 1;
    regions = {};
    r = 1;
    while (i <= length(x))
        width = randi([options.min_width,options.max_width]);
        inxs = find(i < mins & mins <= i+width); % Find mins within range
        if isempty(inxs)
            width = biggest_gap;
            inxs = find(i < mins & mins <= i+width); % Find mins within range
        end
        if isempty(inxs) % Does not contain a max
            last = i+width;
        else
            [v,inx] = min(y(mins(inxs)));
            last = mins(inxs(inx));
        end
        if (last >= length(x))
            last = length(x);
        end
        xsub = x(i:last);
        ysub = y(i:last);
        
        ixs = find(i <= all_maxs & all_maxs <= last);
        sub_maxs = all_maxs(ixs) - i  + 1;
        sub_mins = all_mins(ixs,:) - i  + 1;            
        if ~isempty(sub_maxs)
            [BETA0,lb,ub] = compute_initial_inputs(xsub,ysub,sub_maxs,sub_mins,1:length(xsub));
        else
            BETA0 = [];
            lb = [];
            ub = [];
        end
        regions{r} = {};
        regions{r}.x = xsub;
        regions{r}.y = ysub;
        regions{r}.BETA0 = BETA0;
        regions{r}.lb = lb;
        regions{r}.ub = ub;
        
        i = last + 1;
        r = r + 1;
    end
    
    all_peaks_X = [];
    for r = 1:length(regions)        
        if isempty(regions{r}.BETA0) % Nothing in this region
            continue;
        end
        all_peaks_X = [all_peaks_X;regions{r}.BETA0(4:4:end)];
        if r == 1
            eval_str = sprintf(['x_r=%s;y_r=%s;BETA0_r=%s;lb_r=%s;ub_r=%s;',...
                'x_a=%s;y_a=%s;BETA0_a=%s;lb_a=%s;ub_a=%s;'],...
                mat2str(regions{r}.x'),mat2str(regions{r}.y'),mat2str(regions{r}.BETA0'),mat2str(regions{r}.lb'),mat2str(regions{r}.ub'),...
                mat2str(regions{r+1}.x'),mat2str(regions{r+1}.y'),mat2str(regions{r+1}.BETA0'),mat2str(regions{r+1}.lb'),mat2str(regions{r+1}.ub'));
        elseif r == length(regions)
            eval_str = sprintf(['x_b=%s;y_b=%s;BETA0_b=%s;lb_b=%s;ub_b=%s;',...
                'x_r=%s;y_r=%s;BETA0_r=%s;lb_r=%s;ub_r=%s;'],...
                mat2str(regions{r-1}.x'),mat2str(regions{r-1}.y'),mat2str(regions{r-1}.BETA0'),mat2str(regions{r-1}.lb'),mat2str(regions{r-1}.ub'),...
                mat2str(regions{r}.x'),mat2str(regions{r}.y'),mat2str(regions{r}.BETA0'),mat2str(regions{r}.lb'),mat2str(regions{r}.ub'));
        else
            eval_str = sprintf(['x_b=%s;y_b=%s;BETA0_b=%s;lb_b=%s;ub_b=%s;',...
                'x_r=%s;y_r=%s;BETA0_r=%s;lb_r=%s;ub_r=%s;',...
                'x_a=%s;y_a=%s;BETA0_a=%s;lb_a=%s;ub_a=%s;'],...
                mat2str(regions{r-1}.x'),mat2str(regions{r-1}.y'),mat2str(regions{r-1}.BETA0'),mat2str(regions{r-1}.lb'),mat2str(regions{r-1}.ub'),...
                mat2str(regions{r}.x'),mat2str(regions{r}.y'),mat2str(regions{r}.BETA0'),mat2str(regions{r}.lb'),mat2str(regions{r}.ub'),...
                mat2str(regions{r+1}.x'),mat2str(regions{r+1}.y'),mat2str(regions{r+1}.BETA0'),mat2str(regions{r+1}.lb'),mat2str(regions{r+1}.ub'));
        end
        if ~isempty(outfile)
            fprintf(fid,'s=%d;r=%d;iter=%d;num_regions=%d',1,r,iter,length(regions));
            fprintf(fid,'\t');
            fprintf(fid,'%s',eval_str);
            fprintf(fid,'\n');
        end
        output = sprintf('%ss=%d;r=%d;iter=%d;num_regions=%d\t%s\n',output,1,r,iter,length(regions),eval_str);
    end
%     fprintf('%d\t\t%s\n',iter,mat2str(all_peaks_X));
end
if ~isempty(outfile)
    fclose(fid);
end
