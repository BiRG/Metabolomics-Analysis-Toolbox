function scaled_quotients = quotient_outlyingness( quotients, use_row)
% Returns the outlyingness of quotients
% 
% Quotients differ on a logarithmic scale when doing dilution
% normalization. Otherwise, the midpoint between 1/10, 10/1 is near 5. A
% logarithmic transformation would turn these into -1, 1 and their midpoint
% be 1.
%
% This routine first takes the absolute values of the quotients member of
% collection, then the logarithm. Next it calculates the upper
% and lower quartile and calculates the iqr of the column.  Anything 
% between the two quartiles is assigned an outlyingness of 0. The remainder
% of the values are replaced by their signed distance to their nearest 
% quartile. This is then divided by the iqr.
%
% Only the rows selected by use_row are used in calculating the median, 
% quartiles and iqr.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% quotients        - a real matrix - if empty, then an empty matrix is
%                    returned
%
% use_row          - (optional) a logical row vector. If true then the row 
%                    is used in calculating the iqr and the median. If 
%                    false, the row is still normalized but not used in 
%                    the calculation.  If absent, all rows are used. If 
%                    present, must have he same number of rows as 
%                    quotients. Must have at least 2 true
%                    entries.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% scaled_quotients - the quotients array scaled as defined in the main
%                    description
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% Reviewing these, these are completely inaccurate - probably unupdated
% from a cut-paste session.
%
% TODO: add real examples and test quotient_outlyingness
%
% >> sc = quotient_outlyingness( [0.1,1;0.2,3;4,0.25] )
%
% sc =
%
%   -0.2505         0
%         0    0.5895
%    1.0828   -0.7438
%
% >> sc = iqr_normed_quotients( [0.1,1;0.2,3;4,0.25], false, [true,false,true] )
%
% sc =
%
%   -0.5000    0.5000
%   -0.3121    1.2925
%    0.5000   -0.5000
%
% >> sc = iqr_normed_quotients( [0.1,1;0.2,3;4,0.25], true, [false,false,true] )
%
% sc =
%
%   -3.6889    1.3863
%   -2.9957    2.4849
%         0         0
%
% >> sc = iqr_normed_quotients( [], true, [false,false,true] )
%
% sc =
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

% Return quotients unchanged if it is empty
if numel(quotients) == 0
    scaled_quotients = quotients;
    return;
end


% Set default values for optional inputs
if ~exist('use_row', 'var')
    use_row = true(size(quotients,1),1);
end


% Take care of error conditions
num_rows = sum(use_row);

if num_rows < 2
    error('iqr_normed_quotients:at_least_two_rows', ...
        'The use_row parameter must have at least two true values ');
end

if length(use_row) ~= size(quotients, 1)
    error('iqr_normed_quotients:same_num_rows', ...
        'The use_row parameter must have the same number of entries as the quotients array.');
end    


% Take the log of the absolute value of the quotients. The log makes it
% so 1/10 and 10/1 are equidistant from 1.
abs_quotients = log(abs(quotients));

% Measure the median and quartiles
low_q = prctile(abs_quotients(use_row,:), 25, 1); % Lower quartile
up_q = prctile(abs_quotients(use_row,:), 75, 1); % Upper quartile
rep_low_q = repmat(low_q, size(quotients,1), 1);
rep_up_q = repmat(up_q, size(quotients,1), 1);
rep_iqr = rep_up_q - rep_low_q;

% Do scaling
below_low_q = abs_quotients < rep_low_q;
above_up_q= abs_quotients > rep_up_q;
scaled_quotients = zeros(size(abs_quotients));
scaled_quotients(below_low_q) = abs_quotients(below_low_q)-rep_low_q(below_low_q);
scaled_quotients(above_up_q) = abs_quotients(above_up_q)-rep_up_q(above_up_q);


% Scale the quotients by the IQR (unless the iqr is 0)
non_zero_iqr = rep_iqr ~= 0;
scaled_quotients(non_zero_iqr) = scaled_quotients(non_zero_iqr) ./ rep_iqr(non_zero_iqr);
if any(rep_iqr == 0)
    warning('quotient_outlyingness:zero_iqr',['Zero interquartile range '...
        'encountered in calculating outlyingness. Did not scale those values.']);
end

end

