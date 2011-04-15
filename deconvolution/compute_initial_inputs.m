function [BETA0,lb,ub] = compute_initial_inputs(x,y,maxs,mins,inxs)
min_M = 0.00001;
min_G = 0.00001;
% Compute the initial values for the width/height and offset
BETA0 = [];
lb = [];
ub = [];

for inx = 1:length(maxs)
    try
        g_M = calc_height(max(mins(inx,1),1):min(mins(inx,2),length(y)),y);
        g_G = calc_width(max(mins(inx,1),1):min(mins(inx,2),length(y)),x,y);
    catch ME
        fprintf('Contact Paul :)');
    end    
    % Peaks are not wider than they are tall (initially)
    if g_G > g_M
        g_G = g_M;
    end
    g_P = 0.5;
    lb_x0 = x(min(mins(inx,2),length(y)));
    ub_x0 = x(max(mins(inx,1),1));
    BETA0 = [BETA0;max([g_M,min_M]);max([g_G,min_G]);g_P;x(maxs(inx))];
    lb = [lb;min_M;min_G;0;lb_x0];
    ub = [ub;max(y(inxs));...
        2*abs(x(inxs(1))-x(inxs(end)));1;ub_x0];
end