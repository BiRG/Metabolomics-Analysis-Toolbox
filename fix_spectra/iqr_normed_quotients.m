function scaled_quotients = iqr_normed_quotients( quotients )
% Returns the quotients scaled by their ratio with a quotient-appropriate iqr and shifted so median is 0
% 
% Quotients differ on a logarithmic scale when doing dilution
% normalization. Otherwise, the midpoint between 1/10, 10/1 is near 5. A
% logarithmic transformation would turn these into -1, 1 and their midpoint
% be 1.
%
% This routine first takes the absolute values of the quotients member of
% collection, then the logarithm. Then it takes the iqr or each column then divides everything by
% that iqr. Finally, it subtracts the median.
%
% This procedure is similar to the typical normalization of subtracting 
% the mean and dividing by the standard deviation. Except I use median 
% and iqr and linearize the space by using the logarithm before I start
% normalizing.
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% quotients- a real matrix
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
% >> sc = iqr_normed_quotients( [0.1,1;0.2,3;4,0.25] )
%
% sc =
%
%   -0.2505         0
%         0    0.5895
%    1.0828   -0.7438
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

% Take the absolute value of the log of the quotients. The log makes it
% so 1/10 and 10/1 are equidistant from 1.
abs_quotients = log(quotients);
% Measure the iqr
i_q_r = iqr(abs_quotients);
rep_iqr = repmat(i_q_r, size(quotients,1), 1);
med = prctile(abs_quotients,50);
rep_median = repmat(med, size(quotients,1), 1);
% Scale the quotients by the IQR
scaled_quotients = (abs_quotients - rep_median) ./ rep_iqr ;


end

