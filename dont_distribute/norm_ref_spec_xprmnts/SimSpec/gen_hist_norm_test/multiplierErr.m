function sqerr = multiplierErr( values, multiplier, bins, ref_bins )
% Returns the squared error for a values*multiplier binned in bins, compared to the bin values in ref_bins
%   
% values is a vector of numbers
%
% multiplier is a scalar
%
% bins is an array of bin boundaries suitable for histc_inclusive
%
% ref_bins is an output of histc_inclusive

assert(size(values,1) == 1 || size(values,2) ==1); %Check that values is vector
assert(all(size(multiplier) == [1,1])); % Check that multiplier is a scalar

binned = histc_inclusive(values*multiplier, bins);
sqerr = sum((ref_bins-binned).^2);

end

