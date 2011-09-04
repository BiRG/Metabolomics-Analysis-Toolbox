function [errors, y_baseline] = regularized_model(BETA,x,num_maxima,x_baseline_BETA, orig_data, baseline_area_penalty)
% Note: right now this is not regularized - I am just testing that I can
% modify the function for lsqnonlin rather than lsqcurvefit.  I'll convert
% it into a regularized fit later.
%
% Assumes x_baseline is in sorted order

nRep = 4; % Number of repeating elements
M = @(j) (abs(BETA(nRep*(j-1)+1)));
G = @(j) (abs(BETA(nRep*(j-1)+2)));
sigma = @(j) (G(j)/(2*sqrt(2*log(2))));
P = @(j) (abs(BETA(nRep*(j-1)+3)));
x0 = @(j) (BETA(nRep*(j-1)+4));

if num_maxima >= 1
    fitted_data = P(1)*M(1)*G(1)^2./(4*(x-x0(1)).^2+G(1)^2) + ... % Lorentzian
           (1-P(1))*M(1)*exp(-(x-x0(1)).^2/(2*sigma(1)^2)); % Gaussian
    for i = 2:num_maxima
        fitted_data = fitted_data + P(i)*M(i)*G(i)^2./(4*(x-x0(i)).^2+G(i)^2) + ... % Lorentzian
           (1-P(i))*M(i)*exp(-(x-x0(i)).^2/(2*sigma(i)^2)); % Gaussian
    end    
else
    fitted_data = zeros(size(x));
end
last_inx = nRep*num_maxima;

% Calculate the baseline using the rest of the parameters in BETA (the
% remainder of the parameters) as baseline parameters
remainder = BETA(last_inx+1:end);
y_baseline = baseline_piecewise_interp(remainder,x_baseline_BETA,x);
fitted_data = fitted_data + y_baseline;

% Calculate the area by calculating rectangles (half-rectangles on the ends)
% centered on each x-value with a height of that y value.
if length(x) <= 1
	dx = 1;
else
    x_diffs = abs(x(1:end-1)-x(2:end));
    dx = ([0;x_diffs] +[x_diffs; 0])/2;
end
areas = y_baseline .* dx;
area = sum(abs(areas));

% Tack the area penalty onto the end of the end of the list of individual
% height errors
errors = [fitted_data - orig_data; area*baseline_area_penalty];
