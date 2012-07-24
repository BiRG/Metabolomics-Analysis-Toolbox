function dilutions = rand_dilutions( num_dilutions, range )
% Return a random column vector of length num_dilutions distributed in range
%
% The random values are generated using the default random number
% generator. But are generated in a distribution that is uniform on numbers
% greater than or equal to 1 but for numbers less than 1, P(a,b) is 
% proportional to P(1/b, 1/a) when a < b < 1
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% num_dilutions - scalar. The number of dilution factors to generate. The
%                 number of rows in the returned vector
%
% range         - vector with two entries [min max]. The entries in the
%                 returned vector are distributed in the
%                 half-open interval [min, max) see the description
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% dilutions     - a vector with a single column containing num_dilutions
%                 entries that are distributed in the interval
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

assert(all(range > 0), ...
    'rand_dilutions:only_pos_dilutioons', ...
    'Dilution factors must be greater than 0');

% Set the range so that I can choose uniformly
mn = range(1);
if mn < 1
    mn = 2-1/mn;
end
mx = range(2);
if mx < 1
    mx = 2-1/mx;
end

% Ensure mn < mx
if mn > mx
    t = mn; mn = mx; mx = t;
end

d=mx-mn;
dilutions = rand(num_dilutions, 1).*d+mn;

% Rescale values less than 1 so they fall back into the interval 0..1
to_rescale = dilutions(dilutions < 1);
dilutions(dilutions < 1) = 1./(2-to_rescale);

end

