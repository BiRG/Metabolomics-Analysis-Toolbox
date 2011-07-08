function [member,y_baseline] = fitness(member,y,y_peaks,A,W)
% M = zeros(length(data),1);
% G = zeros(length(data),1);
% P = zeros(length(data),1);
% sigma = zeros(length(data),1);
% X = zeros(length(data),1);
% for inx = 1:length(data)    
%     M(inx) = data{inx}.BETAs{member.pinxs(inx)}(1);
%     G(inx) = data{inx}.BETAs{member.pinxs(inx)}(2);
%     sigma(inx) = G(inx)/(2*sqrt(2*log(2)));
%     P(inx) = data{inx}.BETAs{member.pinxs(inx)}(3);    
%     X(inx) = data{inx}.BETAs{member.pinxs(inx)}(3);
% end
% y_peaks = zeros(size(x));
% for i = 1:length(x)
%     y_peaks(i) = sum(P.*M.*G.^2./(4*(x(i)-X).^2+G.^2) + ... % Lorentzian
%            (1-P).*M.*exp(-(x(i)-X).^2./(2*sigma.^2))); % Gaussian
% end

% catch ME
%     disp('here');
% end

% if ~isempty(baseline_BETA)
%     baseline_options = {};
%     baseline_options.x_all = x;
%     baseline_options.x_baseline_BETA = x_baseline_BETA;
%     y_to_fit = y - y_peaks;
%     
%     model = @(PARAMS,x_) (interp1(x_baseline_BETA,PARAMS,x,'linear'));
%     options = optimset('lsqcurvefit');
%     %options = optimset(options,'MaxIter',10);
%     options = optimset(options,'Display','off');
%     %options = optimset(options,'MaxFunEvals',length(BETA0));
%     [baseline_BETA,R,RESIDUAL,EXITFLAG] = lsqcurvefit(model,baseline_BETA,x,y_to_fit,baseline_lb,0*baseline_ub+max(y_to_fit),options);
%     y_baseline = model(baseline_BETA,x);
% end

y_to_fit = y - y_peaks;
b = W*y_to_fit;

y_baseline = A\b; % Compute the baseline
%y_baseline = 0*y_peaks;

member.y_fit = y_peaks + y_baseline;
member.y_peaks = y_peaks;

% member.y_fit = y_peaks;
% member.y_peaks = y_peaks;
% y_baseline = member.y_peaks*0;

member.r2 = 1 - sum((member.y_fit - y).^2)/sum((mean(y) - y).^2);
