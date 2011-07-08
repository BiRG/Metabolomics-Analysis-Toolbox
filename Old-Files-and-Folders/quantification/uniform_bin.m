function [bins,stats] = uniform_bin(x,Y,width)
global nSpectra
nm = size(Y);
num_samples = nm(2);
if num_samples < 1
    bins = [];
    stats = {};
    return;
end
nSpectra = num_samples;

nm = size(Y);
if nm(2) == 1 % Only 1 sample
    y_sum = Y';
else
    y_sum = sum(abs(Y'));    
end
nonzero_inxs = find(y_sum ~= 0);
i = 1;
all_inxs = {};
while i <= length(nonzero_inxs)
    inxs = [];
    new_inxs = nonzero_inxs(i);
    while (length(new_inxs)-length(inxs)) == 1
        inxs = new_inxs;
        i = i + 1;
        if i > length(nonzero_inxs)
            break;
        end
        new_inxs = inxs(1):nonzero_inxs(i);
    end
    if ~isempty(inxs)
        all_inxs{end+1} = inxs;
    end
end

bins = [];
for i = 1:length(all_inxs)
    inxs = all_inxs{i};
    [tbins,stats] = perform_uniform_bin(x(inxs),width);
    if tbins(1,1) > x(inxs(1))
        tbins(1,1) = x(inxs(1));
    end
    if tbins(end,2) < x(inxs(end))
        tbins(end,2) = x(inxs(end));
    end
    bins = [bins;tbins];
end

%bins = [10,8;8,7;6,5];
%stats = {};
