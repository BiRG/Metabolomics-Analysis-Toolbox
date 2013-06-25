function counts = histc_inclusive( vector, bins )
% Like histc except that the last count includes values == bins(end)
%
% All of the bins from the histc command are open intervals - count of
% values in the range a <= x < b. Then the last bin returned is the count
% of the values exactly equal to b. This command returns the values in
% histc except with the modification that the next to last bin is the 
% values in the range a <= x <= b and the last bin is 0.

counts = histc(vector, bins);
counts(end-1) = counts(end-1) + counts(end);
counts(end) = 0;

end

