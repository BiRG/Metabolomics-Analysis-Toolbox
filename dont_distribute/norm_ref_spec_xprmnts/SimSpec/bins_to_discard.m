function discard_bins = bins_to_discard( binned_spec, discard_x )
% Mark bins which contain x values in discard_x for disposal
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% binned_spec - a struct with a field named x that gives the centers of the
%               bins to use
%
% discard_x   - a vector of values that should be discarded. If a value
%               falls into a bin that bin will be marked for disposal
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% discard_bins - a vector of logicals of the same length as binned_spec.x.
%                It is true iff the corresponding bin contained at least
%                one of the values in discard_x
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.x = [10,20,30,40]; bins_to_discard( f, []) 
% ans = [false, false, false, false]
%
% >> f.x = [10,20,30,40]; bins_to_discard( f, 21) 
% ans = [false, true, false, false]
%
%
% >> f.x = [10,20,30,40]; bins_to_discard( f, [19,21]) 
% ans = [false, true, false, false]
%
% >> f.x = [10,20,30,40]; bins_to_discard( f, [-100,26,500]) 
% ans = [true, false, true, true]
%
% >> f.x = [10,20,30,40]; bins_to_discard( f, [25, 26]) 
% ans = [false, true, true, false]
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

assert(isstruct(binned_spec), 'bins_to_discard:struct', ...
    'The collection passed to bins_to_discard must be a struct.');

assert(isfield(binned_spec,'x'), 'bins_to_discard:x_field', ...
    'The collection passed to bins_to_discard must have a field named ''x''.');

assert(~isempty(binned_spec.x), 'bins_to_discard:x_field_nonempty', ...
    'binned_spec.x must have at least 1 bin center.');

assert(isvector(binned_spec.x), 'bins_to_discard:x_field_vec', ...
    'binned_spec.x must be a vector.');

assert(isempty(discard_x) || isvector(discard_x), ...
    'bins_to_discard:discard_x_is_vector', ...
    'discard_x passed to bins_to_discard must be a vector or empty.');

bin_centers = unique(binned_spec.x);

if isempty(discard_x)
    % Deal with the special case when there are no values to discard
    discard_bins = false(size(bin_centers));
else
    % Make sure that discard_x is a vector so we get the right behavior out
    % of hist
    if length(discard_x) == 1
        discard_x = [discard_x(1), discard_x(1)];
    end
    num_discarded_in_bin = hist(discard_x, bin_centers);
    discard_bins = num_discarded_in_bin > 0;
end

end

