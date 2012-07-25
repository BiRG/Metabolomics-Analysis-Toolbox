function diluted = dilute_spectra( collection, dilutions )
% Divides each spectrum in collection by the corresponding dilution
%
% The result will have the original_multiplied_by field appropriately
% updated (if absent it is treated as if it had been all 1's).
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collection - a struct having a Y field with a 2d array
%
% dilutions  - a numeric vector with the same number of columns as collection.Y
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% diluted - a struct with each column in Y having been divided by the
%           entry in the corresponding column of dilutions. The
%           original_multiplied_by field if present is also divided by the
%           same factors. If absent, it is added with entries 1./dilutions
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.Y = [1,2,4; 2,4,8; 3,6,12]; d=dilute_spectra(f, [1,2,2]); d.Y
%
% d.Y == [1,1,2; 2,2,4; 3,3,6]
%
% d.original_multiplied_by == [1, 0.5, 0.5]
%     
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%
assert(isstruct(collection), 'dilute_spectra:struct', ...
    'The collection passed to dilute_spectra must be a struct.');

assert(isfield(collection, 'Y'), 'dilute_spectra:y_field', ...
    'The collection passed to dilute_spectra must have a Y field.');

assert(isvector(dilutions), 'dilute_spectra:vector_dilutions', ...
    'The dilutions passed to dilute_spectra must be a row vector');

assert(size(dilutions, 2) == size(collection.Y, 2), 'dilute_spectra:vector_dim', ...
    ['The dilutions must have the same number of columns as the number '...
    'of spectra in the collection.']);

assert(all(dilutions > 0), 'dilute_spectra:pos_dilutions', ...
    'All dilutions must be greater than 0.');


mult_factors = {1./dilutions};
diluted = multiply_collections({collection}, mult_factors);
diluted = diluted{1};

end

