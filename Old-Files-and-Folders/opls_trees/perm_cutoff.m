function [asel_bins,stats] = perm_cutoff(labels,bin_data,num_perm,talpha,fold)
[weights, sort_inxs, perm_sorted_weights,perm_weights,correct_q2,q2_perm] = perm_test(bin_data,labels,num_perm,fold);
sel_bins = sort_inxs;

asel_bins = [];
response = is_responding(labels,bin_data,sel_bins,talpha,num_perm,fold);
if response
  sel_bins = trim_until_no_response(labels,bin_data,sel_bins,1/2,talpha,num_perm,fold);
  
  if (numel(sel_bins) == 0)
      asel_bins = sort_inxs;
  else
      ix2 = find(sort_inxs == sel_bins(1));
      asel_bins = sort_inxs(1:ix2-1);
  end
end

stats = {};

