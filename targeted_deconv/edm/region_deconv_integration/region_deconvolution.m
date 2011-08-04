function [BETA,baseline_BETA,fit_inxs,y_fit,y_baseline,R2,peak_inxs,peak_BETA] = region_deconvolution(x,y,BETA0,lb,ub,x_baseline_width,region)
BETA = BETA0;

fit_inxs = find(region(1) >= x & x >= region(2)); % To do: this should adapt to the location of the maxima
y_region = y(fit_inxs);
x_region = x(fit_inxs);

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

region_width = region(1)-region(2);
number_baseline_points_to_insert = round(region_width/x_baseline_width);
x_baseline_BETA = linspace(region(1),region(2),number_baseline_points_to_insert+2)';
xwidth = x(1)-x(2);
baseline_BETA = (y(round((x(1)-x_baseline_BETA)/xwidth)+1) + 0*x_baseline_BETA)/2; % Initialize
lb_baseline = 0*baseline_BETA + min([y_region;0]);
ub_baseline = 0*baseline_BETA + max(y_region);

BETA0_region = [BETA0_region;baseline_BETA];
lb_region = [lb_region;lb_baseline];
ub_region = [ub_region;ub_baseline];
num_maxima = length(inxs);

if num_maxima > 0
    [BETA_region,EXITFLAG] = ...
        perform_deconvolution(x_region',y_region,BETA0_region,lb_region,ub_region,x_baseline_BETA);
    BETA(4*(inxs-1)+1) = BETA_region(1:4:4*num_maxima);
    BETA(4*(inxs-1)+2) = BETA_region(2:4:4*num_maxima);
    BETA(4*(inxs-1)+3) = BETA_region(3:4:4*num_maxima);
    BETA(4*(inxs-1)+4) = BETA_region(4:4:4*num_maxima);
end

[y_fit,y_baseline] = global_model(BETA_region,x_region',num_maxima,x_baseline_BETA);

R2 = 1 - sum((y_fit - y_region).^2)/sum((mean(y_region) - y_region).^2);

peak_inxs = inxs;
peak_BETA = BETA_region(1:4*num_maxima);