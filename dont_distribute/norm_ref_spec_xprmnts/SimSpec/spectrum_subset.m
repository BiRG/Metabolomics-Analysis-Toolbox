function out_col = spectrum_subset( idx1, col1, idx2, col2 )       
% Returns the spectra given by idx* as slices of col*
%
% For each spectral collection struct col1 and col2 there is a
% corresponding index array idx1 and idx2. Choose one pair and call them
% col and idx. For that pair, the spectra specified by idx are extracted
% from col along with the spectrum-specific metadata. Then the data for
% both pairs is combined into a single spectra collection and new global
% metadata is generated based on the metadata in the components. This 
% single spectrum collection is put into a single cell and the result 
% returned.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% idx1 - array that can be used to index into the spectra of col1. 
%
% col1 - a struct containing the data for a spectra collection. Must
%        contain the fields: 'time', 'classification', 'sample_id', 
%        'subject_id', 'sample_description', 'weight', 'units_of_weight', 
%        'species', 'base_sample_id', 'Y','x','collection_id'
%
% idx2 - array that can be used to index into the spectra of col2.
%
% col2 - a struct with the same specs as col1. col1.x must be the same as
%        col2.x
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% o - A single element cell array containing a single spectral collection 
%     formed by concatenating subsets of the input collections. See the
%     description for more details.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
% >> % f(i,j) = i+2*j 
% >> f.Y = repmat((1:10)', 1,5); f.Y = f.Y + repmat(2.*(1:5),10,1); 
% >> f = add_fake_spec_fields(f, 'f', 100);
%
% >> % g(i,j) = i+20*j
% >> g.Y = repmat((1:10)', 1,6); g.Y = g.Y + repmat(20.*(1:6),10,1); 
% >> g = add_fake_spec_fields(g, 'g', 50);
% >> h = spectrum_subset([1,3],f, [5,6],g);
% >> h{1}.Y
% 
% ans =
% 
%      3     7   101   121
%      4     8   102   122
%      5     9   103   123
%      6    10   104   124
%      7    11   105   125
%      8    12   106   126
%      9    13   107   127
%     10    14   108   128
%     11    15   109   129
%     12    16   110   130
% 
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%
local_fields = {'time', 'classification', 'sample_id', 'subject_id', ...
    'sample_description', 'weight', 'units_of_weight', 'species', ...
    'base_sample_id'};
global_req_fields = {'Y','x','collection_id'};

req_fields = horzcat(local_fields, global_req_fields);

if nargin == 2
    out_col.Y = col1.Y(:, idx1);
    
    out_col.time=col1.time(idx1);
    out_col.classification=col1.classification(idx1);
    out_col.sample_id=col1.sample_id(idx1);
    out_col.subject_id=col1.subject_id(idx1);
    out_col.sample_description=col1.sample_description(idx1);
    out_col.weight=col1.weight(idx1);
    out_col.units_of_weight=col1.units_of_weight(idx1);
    out_col.species=col1.species(idx1);
    out_col.base_sample_id=col1.sample_id(idx1);
else
    assert(isstruct(col1) && isstruct(col2),'spectrum_subset:struct', ...
        ['The spectrum collections passed to spectrum_subset must be ', ...
        'structs not cell arrays of structs.']);

    for i=1:length(req_fields)
        cur = req_fields{i};
        assert(isfield(col1, cur) && isfield(col2, cur), ...
            'spectrum_subset:fields',['Spectra collections passed to ' ...
            'spectrum_subset must have field %s'], cur);
    end
    
    assert(all(col1.x == col2.x),'spectrum_subset:one_x', ...
        ['The collections that are combined by spectrum_subset must ' ...
        'have the same set of x values']);
    
    out_col = horzcat_structs(spectrum_subset( idx1, col1 ), spectrum_subset( idx2, col2 ));
    
    out_col.x = col1.x;
    num_samples = size(out_col.Y,2);    
    out_col.num_samples=num_samples; 
    out_col.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
    out_col.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
    out_col.collection_id=sprintf('%s+%s',col1.collection_id, col2.collection_id);
    out_col.type='SpectraCollection';
    out_col.description=sprintf(['Collection created as subset of two '...
        'collections with ids %s and %s'],col1.collection_id,...
        col2.collection_id);
    out_col.processing_log=sprintf('Created by joining collection id %s and %s.',col1.collection_id,col2.collection_id);
    out_col = {out_col};
end

end

