function spec = add_fake_spec_fields( spec, col_id, num_val )
% Adds missing fields to a spectrum collection structure
%
% For testing we often need full-fledged spectrum collection objects but we
% really only care about the values of some of the fields. This will add
% reasonable values to the missing fields. The global text fields will be filled
% in with something based on col_id and the local fields will be filled
% in with something based on num_val. The id of the collection (if it is
% not already set) will be set to col_id.
%
% Any fields that are already present will not be changed.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% spec    - a struct that contains at least a field named 'Y' (note the
%           capitals) that holds a numeric matrix.
%
% col_id  - String value that will be used for creating certain text 
%           fields - in particular, the collection id if it is absent.
%
% num_val - A scalar that will be used in creating many of the numeric
%           fields
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% spec - a struct that has all of the fields necessary for a spectral
%        collection filled in.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> s.Y=[1,2;3,4]; add_fake_spec_fields( s, 'Hey', 2 )
%
% ans = 
% 
%                         Y: [2x2 double]
%               input_names: {1x13 cell}
%     formatted_input_names: {1x13 cell}
%             collection_id: 'Hey'
%                      type: 'SpectraCollection'
%               description: 'Description for col id Hey.'
%            processing_log: 'Added fake fields to col id Hey.'
%               num_samples: 2
%                      time: [2 4]
%                 sample_id: [2 4]
%                subject_id: [2 4]
%                    weight: [2 4]
%            base_sample_id: [2 4]
%                         x: [2x1 double]
%           units_of_weight: {'stone'  'stone'}
%            classification: {1x2 cell}
%        sample_description: {1x2 cell}
%                   species: {1x2 cell}
% 
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

assert(isfield(spec, 'Y'),'add_fake_spec_fields:cant_fake_y', ['The ' ...
    'spectrum to which fake fields are added must have a Y field.']);

num_samples = size(spec.Y, 2);

if ~isfield(spec, 'input_names')
    spec.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
end

if ~isfield(spec, 'formatted_input_names')
    spec.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
end

if ~isfield(spec, 'collection_id')
    spec.collection_id=col_id;
end

if ~isfield(spec, 'type')
    spec.type='SpectraCollection';
end

if ~isfield(spec, 'description')
    spec.description=['Description for col id ' col_id '.'];
end

if ~isfield(spec, 'processing_log')
    spec.processing_log=['Added fake fields to col id ' col_id '.'];
end

if ~isfield(spec, 'num_samples')
    spec.num_samples=num_samples; 
end

num_fields = {'time', 'sample_id', 'subject_id', 'weight', 'base_sample_id'};
for i = 1:length(num_fields)
    f=num_fields{i};
    if ~isfield(spec, f)
        spec.(f)=num_val.*(1:num_samples);
    end
end

if ~isfield(spec, 'x')
    spec.x=linspace(-1,12,size(spec.Y,1))'; 
end

if ~isfield(spec, 'units_of_weight')
    spec.units_of_weight=arrayfun(@(x) 'stone',1:num_samples,'UniformOutput',false);
end

if ~isfield(spec, 'classification')
    spec.classification=arrayfun(@(x) ...
        sprintf('Classification for sample id %g',x),spec.subject_id, ...
        'UniformOutput',false);
end

if ~isfield(spec, 'sample_description')
    spec.sample_description=arrayfun(@(x) ...
        sprintf('Description for sample id %g',x),spec.subject_id, ...
        'UniformOutput',false);
end

if ~isfield(spec, 'species')
    spec.species=arrayfun(@(x) ...
        sprintf('Species for sample id %g',x),spec.subject_id, ...
        'UniformOutput',false);
end

end

