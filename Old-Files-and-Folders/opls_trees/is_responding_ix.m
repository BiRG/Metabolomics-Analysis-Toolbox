function [isr,weights] = is_responding_ix(labels,bin_data,sel_bins,talpha,num_perm,fold,ix)
% print_to_arff('perm.arff',labels,bin_data,sel_bins);
% [perm_sorted_weights,weights,sort_inxs] = run_perm('perm.arff');
[weights, sort_inxs, perm_sorted_weights, perm_weights, q2_correct, q2_perm] = perm_test(bin_data(:,sel_bins),labels,num_perm,fold);

sorted = sort(q2_perm,'descend');
thres = sorted(ix+1);
if q2_correct >= thres
    isr = true;
else
    isr = false;
end

% save('test','perm_sorted_weights','weights')
% nm2 = size(perm_sorted_weights);
% num_perm = nm2(1);
% min_sses = Inf*ones(1,num_perm);
% for p1 = 1:num_perm
%   for p2 = 1:num_perm
%     if p1 ~= p2
%       new_sse = sum(((perm_sorted_weights(p1,:)-perm_sorted_weights(p2,:))./perm_sorted_weights(p1,:)).^2);
%       if new_sse < min_sses(p1)
%         min_sses(p1) = new_sse;
%       end
%     end
%   end
% end
% sorted = sort(min_sses,'descend');
% ix = round(num_perm*talpha);
% thres = sorted(ix);
% 
% mnw = Inf;
% for p2 = 1:num_perm
%   new_sse = sum(((weights-perm_sorted_weights(p2,:))./weights).^2);
%   if new_sse < mnw
%     mnw = new_sse;
%   end
% end
% 
% if mnw > thres % Found something
%   isr = true;
% else % Nothing more than random noise
%   isr = false;
% end
