function n_bins = freedman_diaconis( data )
% Returns the number of histogram bins needed to bin the one-dimensional data using the Freedman-Diaconis rule
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% data - a one-dimensional array of data values
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% n_bins - a scalar giving the number of bins to use from the
%          freeman-diaconis rule (2*IQR*n^(1/3))
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> n_bins = freedman_diaconis([1,1,2,2,3,3,3,3,3,3,6])
% 
% n_bins will be 2 = ceil(2*1.5*(8^-1/3))
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%

d_vec = reshape(data,[],1);
n_bins = ceil(2*iqr(d_vec)*(length(d_vec)^(-1/3)));

end

