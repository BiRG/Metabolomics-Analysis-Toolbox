function out_col = spectrum_subset( idx1, col1, idx2, col2 )       
%SPECTRUM_SUBSET stub but possibly a working stub
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
    out_col.processing_log=sprintf('Created by joining id %d and %d.',col1.collection_id,col2.collection_id);
    out_col = {out_col};
end

end

