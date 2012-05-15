function str = spectrum_properties_string( collection, index )
% Return a string describing the properties of spectrum index in collection
%
%
% Ignores the type', 'description', and 'processing_log' properties.
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collection  - A spectral collection. A struct. One of the members of a
%               cell array returned by load_collections.m in
%               common_scripts. 
%
% index       - The index of a spectrum within the collection. Returns
%               a string describing this spectrum's properties
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% str - the string describing the properties of the given spectrum
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> str = spectrum_properties_string( collection, index )
%
% str = 'CollectionID: 
%        127
%        units of weight: 
%        lb'
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (May 2012) eric_moyer@yahoo.com
%
fns = collection.formatted_input_names;
ignore={'type', 'description', 'processing_log'};
num_ignored = sum(cellfun(@(in) any(strcmp(in, fns)), ignore));
out = cell(length(fns)-num_ignored,1);
num_spectra = collection.num_samples;
cur_idx = 1;

for i = 1:length(fns)
    fn = fns{i};
    
    if ~any(strcmp(ignore, fn)) %If we are not ignoring the given fieldname
        value = collection.(fn);
        if length(value) == num_spectra
            if iscell(value)
                value = value{index};
            else
                value = value(index);
            end
            if isnumeric(value) && numel(value) == 1
                value = sprintf('%g', value);
            else
                value = to_str(value);
            end
        end
        out{cur_idx}=sprintf('%s:\n%s\n\n', collection.input_names{i}, value);
        cur_idx = cur_idx + 1;
    end
end

str = [out{:}];

end

