function dilutions = rand_dilutions( num_dilutions, range )
% Return a random column vector of length num_dilutions uniformly distributed in range
%
% The random values are generated using the default random number
% generator.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% num_dilutions - scalar. The number of dilution factors to generate. The
%                 number of rows in the returned vector
%
% range         - vector with two entries [min max]. The entries in the
%                 returned vector are uniformly distributed in the
%                 half-open interval [min, max)
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% dilutions     - a vector with a single column containing num_dilutions
%                 entries that are uniformly distributed in the interval
%                 given by range.
%
% -------------------------------------------------------------------------
% Example
% -------------------------------------------------------------------------
%
% >> factors = rand_dilutions(5, [2, 10])
%
% Returns a column vector with 5 entries, all of which are in the half-open
% interval [2,10)
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

d=range(2)-range(1);
dilutions = rand(num_dilutions, 1).*d+range(1);

end

