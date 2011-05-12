function [y_fit,fit_inxs,MGPX,baseline_BETA,x_baseline_BETA,xmaxs,converged] = curve_fit_helper(collections,i,j,left,right,far_left,far_right)
xmaxs = collections{i}.spectra{j}.xmaxs;
fit_inxs = find(far_left >= collections{i}.x & collections{i}.x >= far_right);
far_left = collections{i}.x(fit_inxs(1));
far_right = collections{i}.x(fit_inxs(end));
inxs = find(far_left >= xmaxs & xmaxs >= far_right);
X = xmaxs(inxs);
[y_fit,MGPX,baseline_BETA,x_baseline_BETA,converged] = curve_fit(collections{i}.x,collections{i}.Y(:,j),fit_inxs,X,xmaxs,far_left,far_right);
xmaxs(inxs) = MGPX(4:4:end);