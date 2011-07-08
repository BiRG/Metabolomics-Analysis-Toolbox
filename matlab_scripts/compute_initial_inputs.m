function [BETA0,lb,ub] = compute_initial_inputs(x,y,all_X,fit_inxs,X)
min_M = 0.00001;
min_G = 0.00001;
% Compute the initial values for the width/height and offset
BETA0 = [];
lb = [];
ub = [];
% Assign all of the Xs to the closest index in x
max_inxs = zeros(size(all_X));
for mx_inx = 1:length(max_inxs)
    diff = abs(x - all_X(mx_inx));
    [vs,inxs] = sort(diff);
    max_inxs(mx_inx) = inxs(1);
end
for mx_inx = 1:length(X)
    inx = find(all_X == X(mx_inx));
    % Left
    if inx-1 >= 1
        temp_inxs = max_inxs(inx-1):max_inxs(inx)-1;
    else
        temp_inxs = fit_inxs(1):max_inxs(inx)-1;
    end
    if isempty(temp_inxs)
        temp_inxs = max_inxs(inx);
    end
    [mn,ix]=min(y(temp_inxs));
    left_inx = temp_inxs(ix);
    ub_x0 = x(left_inx);
    
    % Right
    if inx+1 <= length(all_X)
        temp_inxs = max_inxs(inx)+1:max_inxs(inx+1);
    else
        temp_inxs = max_inxs(inx)+1:fit_inxs(end);
    end
    if isempty(temp_inxs)
        temp_inxs = max_inxs(inx);
    end
    [mn,ix]=min(y(temp_inxs));
    right_inx = temp_inxs(ix);
    lb_x0 = x(right_inx);
    
    g_M = calc_height(left_inx:right_inx,y);
    g_G = calc_width(left_inx:right_inx,x,y);
    % Peaks are not wider than they are tall (initially)
    if g_G > g_M
        g_G = g_M;
    end
    g_P = 0.5;
    if lb_x0 == ub_x0
        width = abs(x(1)-x(2));
        lb_x0 = lb_x0 - width/2;
        ub_x0 = ub_x0 + width/2;
    end
    BETA0 = [BETA0;max([g_M,min_M]);max([g_G,min_G]);g_P;X(mx_inx)];
    lb = [lb;0;0;0;lb_x0];
    ub = [ub;max(y(fit_inxs));...
        2*abs(x(fit_inxs(1))-x(fit_inxs(end)));1;ub_x0];
end