function [BETA,baseline_BETA,y_fit,y_baseline,R2] = region_deconvolution(x,y,BETA0,lb,ub,x_baseline_BETA,region)
BETA = BETA0;
baseline_BETA = baseline_BETA0;

% Construct region
X = BETA0(4:4:end);
inxs = find(region(1) >= X & X >= region(2));
lb_region = [];
ub_region = [];
BETA0_region = [];
for i = 1:length(inxs)
    ix = inxs(i);
    lb_region = [lb_region;lb(4*(ix-1)+(1:4))];
    ub_region = [ub_region;ub(4*(ix-1)+(1:4))];
    BETA0_region = [BETA0_region;BETA0(4*(ix-1)+(1:4))];
end
BETA0_region = [BETA0_region;baseline_BETA0];
lb_region = [lb_region;min([y_region;0]);min([y_region;0])];
ub_region = [ub_region;max(y_region);max(y_region)];
num_maxima = length(inxs);

if num_maxima > 0
    [BETA_region,EXITFLAG] = ...
        perform_deconvolution(x',y,[BETA0_region;baseline_BETA0],lb_region,ub_region,x_baseline_BETA);
    BETA(4*(inxs-1)+1) = BETA_region(1:4:4*num_maxima);
    BETA(4*(inxs-1)+2) = BETA_region(2:4:4*num_maxima);
    BETA(4*(inxs-1)+3) = BETA_region(3:4:4*num_maxima);
    BETA(4*(inxs-1)+4) = BETA_region(4:4:4*num_maxima);
end

[y_fit,y_baseline] = global_model(BETA,x',x_baseline_BETA);

R2 = 1 - sum((y_fit - y).^2)/sum((mean(y) - y).^2);