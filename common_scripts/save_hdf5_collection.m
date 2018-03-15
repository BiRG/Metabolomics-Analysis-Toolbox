function save_hdf5_collection(collection, path)
if exist(path, 'file')==2
  delete(path);
end
fid = H5F.create(path);
H5F.close(fid);
keys = fieldnames(collection);
protected_keys = {'owner', 'createdBy', 'processing_log', 'collection_id', 'input_names', 'formatted_input_names', 'base_sample_id', 'filename'};
for i = 1:size(keys,1)
    key = keys{i};
    value = collection.(key);
    if ~size(find(ismember(key, protected_keys),1))
        if isnumeric(collection.(key))
            h5create(path, ['/' key], size(value))
            h5write(path, ['/' key], value);
        else
            h5writeatt(path, '/', key, value);
        end
    end
end
h5writeatt(path, '/', 'processingLog', collection.('processing_log'));
end
