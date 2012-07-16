function [ bin_boundaries ] = equal_frequency_histogram_boundaries( data, num_bins )
% Return the boundaries of num_bins finite bins in an equal-frequency histogram of data
%
% bin_boundaries = EQUAL_FREQUENCY_HISTOGRAM_BOUNDARIES( data, num_bins )
%
% The lowest bin boundary is the min of the data-set. Then, the upper
% boundaries of each bin is set starting with this one. For each bin,
% let num_entries be the number of entries not yet in any bin. Let
% num_bins be the number of bins remaining without an upper
% boundary. Set the upper boundary so that there are at least
% ceil(num_entries/num_bins) entries in the bin. 
% Take the value half-way between the two adjacent entries in the
% sorted list, except for the last bin, in which case, the maximum of
% the list is taken. This is repeated for the next bin with
% num_entries being reduced by the number of entries in the previous
% bin and the number of bins being reduced by 1.
%
% If the number of entries is reduced to 0 before the last bin is
% filled, the remaining bins are set equal-width based on the mean
% width of the previous bins. If the mean width is 0 or infinite, then
% the remaining bins are width 1. If there are no preceeding bins, the
% lower bound is 0.
%
% At the very end, the lower bound on the first bin and the upper
% bound on the last bin are both potentially adjusted so that the
% width of each bin is at least 5 times the standard deviation of the
% elements that fall into the bin. If a bin already has a greater
% width, it is left alone. If there are less than 2 elements in a
% bin, it is left alone.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% data     - a 1-d vector of numbers. The distribution of these entries
%            determines the location of the bin boundaries. All entries
%            that are infinite or NaN are ignored as if they had not been 
%            present in the data.
%
% num_bins - a scalar. The number of bins to use in the histogram. Must be 
%            at least 1
%
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% bin_boundaries - The bins derived from the algorithm. See the description
%                  above. bin_boundaries(i) is a number (or +/- infinity).
%                  bin_boundaries(i), bin_boundaries(i+1) are the lower and
%                  upper boundaries of the i'th bin.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> equal_frequency_histogram_boundaries( [1,1,1,2,3,4,5,5,5,5,5,6], 4 )
%
% ans =
% 
%     1.0000    1.5000    4.5000    5.5000    6.0000
% 
% >> equal_frequency_histogram_boundaries( [1,1,1,2,3,4,5,5,5,5,5,6], 3 )
%
% ans =
% 
%          0    2.5000    5.5000    6.0000
% 
% >> equal_frequency_histogram_boundaries( [1,1,1,2,3,4,5,5,5,5,5,5], 3 )
%
% ans =
% 
%          0    2.5000    5.0000    7.0000
%
% >> equal_frequency_histogram_boundaries( [5,1,1,2,3,4,5,5,5,5,5,1], 5 )
%
% ans =
% 
%     1.0000    1.5000    4.5000    5.0000    6.3333    7.6667
%
% >> equal_frequency_histogram_boundaries( [-inf,1,10,20,22,24,inf,25,25,25,26,26,26,27,nan], 4 )
%
% ans =
% 
%   -26.5219   21.0000   25.5000   26.5000   27.0000
%
% >> equal_frequency_histogram_boundaries( [], 4 )
%
% ans =
% 
%      0     1     2     3     4
%
% >> equal_frequency_histogram_boundaries( [-inf,inf], 4 )
%
% ans =
% 
%      0     1     2     3     4
%
% >> equal_frequency_histogram_boundaries( [1,2,3,10,20], 2 )
%
% ans = 
%
%     1.0000    6.5000   41.8553
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

data=sort(data(~isnan(data) & ~isinf(data)));

bin_boundaries=zeros(1,num_bins+1); % Note that this sets the lower bound of the first bin to 0 if there is no data, fulfilling a special case in the spec
if ~isempty(data)
    bin_boundaries(1)=min(data);
end

% Make bin assignments under normal cases (where we don't run out of
% elements before running out of bins
cur_bin = 1; % The next bin to create
last_index_in_bin = 0; % The last index of data that lies in a currently created bin
while(cur_bin <= num_bins && last_index_in_bin < length(data))
    num_remain_bins = num_bins - cur_bin + 1;
    num_remain_elements = length(data) - last_index_in_bin;
    % These two asserts should be ensured by loop conditions
    assert(num_remain_bins > 0); 
    assert(num_remain_elements > 0);
    
    min_elts_in_cur_bin = ceil(num_remain_elements / num_remain_bins);
    last_index_in_cur_bin = min(...
        length(data), ...
        last_index_in_bin + min_elts_in_cur_bin);
    while last_index_in_cur_bin < length(data) && ...
            data(last_index_in_cur_bin) == data(last_index_in_cur_bin + 1) 
        last_index_in_cur_bin = last_index_in_cur_bin + 1;
    end
    if last_index_in_cur_bin < length(data)
        bin_boundaries(cur_bin+1) = (data(last_index_in_cur_bin) + ...
            data(last_index_in_cur_bin+1))/2;
    else
        bin_boundaries(cur_bin+1) = data(last_index_in_cur_bin);
    end
    
    last_index_in_bin = last_index_in_cur_bin;
    cur_bin = cur_bin + 1;
end

% Handle the case where we ran out of elements before running out of bins
if cur_bin <= num_bins
    % This should be true because it is the only way to get out of the
    % previous loop above when cur_bin <= num_bins
    assert(last_index_in_bin >= length(data));
    % This should be true because we start cur_bin at 1 and only increase
    % it
    assert(cur_bin >= 1);
    
    new_bin_width = 0;
    if cur_bin > 1
        lower_bounds = bin_boundaries(1:cur_bin-1);
        upper_bounds = bin_boundaries(2:cur_bin);
        bin_widths = upper_bounds - lower_bounds;
        new_bin_width = mean(bin_widths);        
    end
    if new_bin_width <= 0 || isinf(new_bin_width)
        new_bin_width = 1;
    end
    num_remain_bins = num_bins - cur_bin + 1;
    last_bin_ub = bin_boundaries(cur_bin);
    for i=1:num_remain_bins
        bin_boundaries(cur_bin+i) = last_bin_ub+i*new_bin_width;
    end;
end

% Extend the first and last bins to 5 std-dev wide
data_in_first_bin = data(data >= bin_boundaries(1) & data < bin_boundaries(2));
if length(data_in_first_bin) > 1
    min_width = 5*std(data_in_first_bin);
    bin_boundaries(1) = min(bin_boundaries(1), bin_boundaries(2)-min_width);
end

data_in_last_bin = data(data >= bin_boundaries(end-1) & data <= bin_boundaries(end));
if length(data_in_last_bin) > 1
    min_width = 5*std(data_in_last_bin);
    bin_boundaries(end) = max(bin_boundaries(end), bin_boundaries(end-1)+min_width);
end

end