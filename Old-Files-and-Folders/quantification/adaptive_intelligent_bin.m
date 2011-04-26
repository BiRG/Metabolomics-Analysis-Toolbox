function [bins,stats] = adaptive_intelligent_bin(x,Y,R,start_left,end_right)
global params num_splits_checked num_noise_splits_checked
spectra = {};
nm = size(Y);
for s = 1:nm(2)
    spectra{s}.x = x;
    spectra{s}.y = Y(:,s);
end
params.spectra = spectra;
mx_x = max(spectra{1}.x);
xwidth = abs(spectra{1}.x(1)-spectra{1}.x(2));

% First compute Vnoise
% For the left noise region
noise_left_inx = 1;
noise_right_inx = round((mx_x-start_left)/xwidth)+1;
Vnoise = 0;
num_splits_checked = 0;
noise_results = recurse(R,Vnoise,noise_left_inx,noise_right_inx);
% For the right noise region
noise_left_inx = round((mx_x-end_right)/xwidth)+1;
noise_right_inx = length(spectra{1}.x);
new_noise_results = recurse(R,Vnoise,noise_left_inx,noise_right_inx);
num_noise_splits_checked = num_splits_checked;
num_splits_checked = 0;
noise_results = {noise_results{:},new_noise_results{:}};
% Calculate the new Vnoise
for b = 1:length(noise_results)
    Vbn = Vb(R,noise_results{b}(1),noise_results{b}(2));
    if Vbn > Vnoise
        Vnoise = Vbn;
    end
end

% Now bin up the entire spectrum
start_inx = round((mx_x-start_left)/xwidth)+1;
end_inx = round((mx_x-end_right)/xwidth)+1;
results = recurse(R,Vnoise,start_inx,end_inx);
bins = zeros(length(results),2);
for b = 1:length(results)
    bins(b,:) = spectra{1}.x(results{b});
end

stats = {};
stats.num_splits_checked = num_splits_checked;
stats.num_noise_splits_checked = num_noise_splits_checked;

function results = recurse(R,Vnoise,left_inx,right_inx)
split_inx_max = BEC(R,Vnoise,left_inx,right_inx);
if split_inx_max == 0
    results = {[left_inx,right_inx]};
else
    left_inx1 = left_inx;
    right_inx1 = split_inx_max;
    left_inx2 = split_inx_max;
    right_inx2 = right_inx;
    results1 = recurse(R,Vnoise,left_inx1,right_inx1);
    results2 = recurse(R,Vnoise,left_inx2,right_inx2);
    results = {results1{:},results2{:}};
end

function split_inx_max = BEC(R,Vnoise,left_inx,right_inx)
global num_splits_checked split_arguments
Vbmax = 0;
Vb1max = 0;
Vb2max = 0;
split_inx_max = 0;
% Try all of the different splits
for split_inx = (left_inx+1):(right_inx-1)
    num_splits_checked = num_splits_checked + 1;
%     split_arguments{end+1} = {};
%     split_arguments{end}.left_inx = left_inx;
%     split_arguments{end}.right_inx = right_inx;
%     split_arguments{end}.split_inx = split_inx;
    Vb1 = Vb(R,left_inx,split_inx);
    Vb2 = Vb(R,split_inx,right_inx);
    Vbsum = Vb1 + Vb2;
    if Vbsum > Vbmax
        Vbmax = Vbsum;
        split_inx_max = split_inx;
        Vb1max = Vb1;
        Vb2max = Vb2;
    end
end
Vb = Vb(R,left_inx,right_inx);
% If not split then, set the split_inx_max to 0
if ~(Vbmax > Vb && Vb1max > Vnoise && Vb2max > Vnoise)
    split_inx_max = 0;
end

function Vbv = Vb(R,left_inx,right_inx)
global params
inxs = left_inx:right_inx; % 1 assignment
Vbv = 0; % 1 assignment
for j = 1:length(params.spectra) % length(spectra) assignments
    maxj = max(params.spectra{j}.y(inxs)); % max of N items takes N - 1 comparisons, 1 assignment
    Ij1 = params.spectra{j}.y(left_inx); % 1 assignment
    Ijend = params.spectra{j}.y(right_inx); % 1 assignment
    Vbv = Vbv + ((maxj - Ij1)*(maxj - Ijend))^R; % 3 add_sub, 1 mult_div, 1 exponent, 1 assignment
end
Vbv = Vbv/length(params.spectra); % 1 div, 1 assignment
