function [bins,stats] = perform_uniform_bin(x,width)
bins = [];
left = max(x);
right = left - width;
while left >= min(x)
    bins(end+1,:) = [left,right];
    left = left-width;
    right = right-width;
end
bins(end,2) = min(x);

stats = {};