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
% floor(num_entries/num_bins) entries in the bin. Take the value
% half-way between the two adjacent entries in the sorted list, except
% for the last bin, in which case, the maximum of the list is
% taken. This is repeated for the next bin with num_entries being
% reduced by the number of entries in the previous bin and the number
% of bins being reduced by 1.
%
% If the number of entries is reduced to 0 before the last bin is
% filled, the remaining bins are set equal-width based on the mean
% width of the previous bins. If the mean width is 0 or infinite, then
% the remaining bins are width 1.
%
% At the very end, the lower bound on the first bin and the upper
% bound on the last bin are both potentially adjusted so that the
% width of each bin is at least 5 times the standard deviation of the
% elements that fall into the bin. If a bin already has a greater
% width, it is left alone. If there are less than 3 elements in a
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
% >> EQUAL_FREQUENCY_HISTOGRAM_BOUNDARIES( [1,1,1,2,3,4,5,5,5,5,5,6], 4 )
%
% ans = [1,1.5,4.5,5.5,6]
%
% >> EQUAL_FREQUENCY_HISTOGRAM_BOUNDARIES( [1,1,1,2,3,4,5,5,5,5,5,6], 3 )
%
% ans = [0,2.5,5.5,6]
%
% >> EQUAL_FREQUENCY_HISTOGRAM_BOUNDARIES( [1,1,1,2,3,4,5,5,5,5,5,5], 3 )
%
% ans = [0,2.5,5,7]
%
% >> EQUAL_FREQUENCY_HISTOGRAM_BOUNDARIES( [1,1,1,2,3,4,5,5,5,5,5,5], 5 )
%
% ans = [1,1.5,3.5,5,6.333,7.667]
%
% >> EQUAL_FREQUENCY_HISTOGRAM_BOUNDARIES( [-inf,1,10,20,22,24,25,25,25,26,26,26,27,nan], 4 )
%
% ans = [-26.5219,21,25.5,26.5,27]
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%


end

