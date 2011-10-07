function output = mapper(stdin,outfile)
data = process_stdin(stdin);
output = '';

% Loop through each region
for inx = 1:length(data)
  data{inx}.new_eval_strs = {};
  data{inx}.lb = {};
  data{inx}.ub = {};
  data{inx}.x = {};
  data{inx}.y = {};
  data{inx}.BETA0 = {};
  data{inx}.num_maxima = {};
  data{inx}.x_baseline_BETA = {};
  for j = 1:length(data{inx}.eval_strs) % Could be more than 1 but for now there is only 1
    % Core of the algorithm
    eval_str = data{inx}.eval_strs{j};
    eval(eval_str);
    r = data{inx}.r;
    if r == 1
        num_maxima = length(BETA0_r)/4 + length(BETA0_a)/4;
        x = [x_r';x_a'];
        y = [y_r';y_a'];
%         BETA0 = [BETA0_r';BETA0_a';y_r(1);y_a(1);y_a(end)];
        BETA0 = [BETA0_r';BETA0_a';y_r(1);y_a(end)];
%         x_baseline_BETA = [x_r(1);x_a(1);x_a(end)];
%         lb = [lb_r';lb_a';min(y);min(y);min(y)];
%         ub = [ub_r';ub_a';max(y);max(y);max(y)];
        x_baseline_BETA = [x_r(1);x_a(end)];
        lb = [lb_r';lb_a';min(y);min(y)];
        ub = [ub_r';ub_a';max(y);max(y)];
    elseif r == data{inx}.num_regions
        num_maxima = length(BETA0_b)/4 + length(BETA0_r)/4;
        x = [x_b';x_r'];
        y = [y_b';y_r'];
        BETA0 = [BETA0_b';BETA0_r';y_b(1);y_r(end)];
%         BETA0 = [BETA0_b';BETA0_r';y_b(1);y_r(1);y_r(end)];
%         x_baseline_BETA = [x_b(1);x_r(1);x_r(end)];
%         lb = [lb_b';lb_r';min(y);min(y);min(y)];
%         ub = [ub_b';ub_r';max(y);max(y);max(y)];
        x_baseline_BETA = [x_b(1);x_r(end)];
        lb = [lb_b';lb_r';min(y);min(y)];
        ub = [ub_b';ub_r';max(y);max(y)];
    else
        num_maxima = length(BETA0_b)/4 + length(BETA0_r)/4 + length(BETA0_a)/4;
        x = [x_b';x_r';x_a'];
        y = [y_b';y_r';y_a'];
%         BETA0 = [BETA0_b';BETA0_r';BETA0_a';y_b(1);y_r(1);y_a(1);y_a(end)];
        BETA0 = [BETA0_b';BETA0_r';BETA0_a';y_b(1);y_a(end)];
%         x_baseline_BETA = [x_b(1);x_r(1);x_a(1);x_a(end)];
%         lb = [lb_b';lb_r';lb_a';min(y);min(y);min(y);min(y)];
%         ub = [ub_b';ub_r';ub_a';max(y);max(y);max(y);max(y)];
        x_baseline_BETA = [x_b(1);x_a(end)];
        lb = [lb_b';lb_r';lb_a';min(y);min(y)];
        ub = [ub_b';ub_r';ub_a';max(y);max(y)];
    end
    data{inx}.lb{j} = lb;
    data{inx}.ub{j} = ub;
    data{inx}.x{j} = x;
    data{inx}.y{j} = y;
    data{inx}.BETA0{j} = BETA0;
    data{inx}.num_maxima{j} = num_maxima;
    data{inx}.x_baseline_BETA{j} = x_baseline_BETA;
  end
end
for inx = 1:length(data)
  for j = 1:length(data{inx}.eval_strs) % Could be more than 1 but for now there is only 1
    [data{inx}.new_eval_strs{j},y_fit] = perform_deconvolution(data{inx}.x{j},data{inx}.y{j},data{inx}.BETA0{j},...
        data{inx}.lb{j},data{inx}.ub{j},data{inx}.num_maxima{j},data{inx}.x_baseline_BETA{j});
  end
end

% Output results
if exist('outfile') && ~isempty(outfile)
    fid = fopen(outfile,'w');
end
for inx = 1:length(data)
    r = data{inx}.r;
    for j = 1:length(data{inx}.eval_strs) % For now only 1      
        eval_str = data{inx}.eval_strs{j};
        eval(eval_str);    
        orig_BETA = BETA0_r;
        if r == 1
            region_inxs = 1:length(BETA0_r);
        elseif r == data{inx}.num_regions
            region_inxs = (length(BETA0_b)+1):(length(BETA0_b)+length(BETA0_r));
        else
            region_inxs = (length(BETA0_b)+1):(length(BETA0_b)+length(BETA0_r));
        end    
        eval(data{inx}.new_eval_strs{j});
        new_BETA = BETA(region_inxs);
        for p = 1:length(new_BETA)/4
            new_res_str = sprintf('%f\t%s\n',orig_BETA(4*(p-1)+4),mat2str(new_BETA(4*(p-1)+(1:4))));
            if exist('outfile') && ~isempty(outfile)
                fprintf(fid,new_res_str);
            elseif ~exist('outfile');
                fprintf(new_res_str);
            else
                output = sprintf('%s%s',output,new_res_str);
            end
        end
    end
end
if exist('outfile') && ~isempty(outfile)
    fclose(fid);
end