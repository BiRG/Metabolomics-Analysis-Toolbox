function indices = subset_indices( num_in_subset, collection )
% Return indices to a random subset of the spectra in collection
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% num_in_subset - a scalar. The number of spectra in the subset. Must be at
%                 least 0 and at most the number of spectra in the
%                 collection.
% 
% collection    - a struct with a field called Y that holds a numeric array.
%                 The columns are spectra.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% indices - collection.Y(:,indices) contains the selected subset
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.Y=[1,2,4; 10,2,4; 1,20,4]; subset_indices(1, f)
%
% Returns a random number from 1 to 3 inclusive.
% 
% >> f.Y=[1,2,4; 10,2,4; 1,20,4]; subset_indices(2, f)
%
% Returns [1 2], [2 1], [2 3], [3 2], [1 3], or [3 1] - depending on the
% random number generator.
%     
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

assert(isstruct(collection), 'subset_indices:struct', ...
    'The collection passed to subset indices must be a struct.');

assert(isfield(collection, 'Y'), 'subset_indices:hasYField', ...
    ['The collection passed to subset indices must have a field '...
    'named Y.']);

assert(num_in_subset >= 0, 'subset_indices:non_neg_size', ...
    'The selected subset size cannot be negative.');

assert(num_in_subset <= size(collection.Y,2), ...
    'subset_indices:too_large_subset', ...
    ['The subset size cannot be larger than the number of spectra ' ...
    'from which the subset is taken.']);

indices = randperm(size(collection.Y,2));
indices = indices(1:num_in_subset);

end

