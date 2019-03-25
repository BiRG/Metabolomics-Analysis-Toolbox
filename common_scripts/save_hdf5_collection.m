function save_hdf5_collection(collection, path)
% Write the collection structure to an hdf5 file
% This will save numeric attributes as datasets
% that may not be ideal behavior
% it might be better to save such attributes as strings.
if exist(path, 'file')==2
  delete(path);
end
fid = H5F.create(path);
H5F.close(fid);
keys = fieldnames(collection);
protected_keys = {'owner', 'num_samples', 'createdBy', 'collection_id', 'input_names', 'formatted_input_names', 'base_sample_id', 'filename'};
collection.description = collection.processing_log;
for i = 1:size(keys,1)
    key = keys{i};
    value = collection.(key);
    if ~size(find(ismember(key, protected_keys),1))
        if isnumeric(value) && sum(size(value)) ~= 2
            h5create(path, ['/' key], size(value')) % some weird hdf5 row vs. column stuff
            h5write(path, ['/' key], value');
        elseif iscell(value)
            write_cell_array(path, key, value);
        else
            try
                if ~strcmp(value, '')
                    value_size = size(value);
                    if value_size(1) == max(value_size)
                        value = value';
                    end
                    h5writeatt(path, '/', key, value);
                end
            catch error
                fprintf('Could not write %s: %s', key, error.identifier);
            end
        end
    end
end
end
