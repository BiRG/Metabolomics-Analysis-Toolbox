function collection = load_hdf5_collection(path)
file_info = h5info(path);
collection = struct;
collection(:).('filename') = file_info.Filename;
[~,basename,~] = fileparts(path);
collection(:).('collection_id') = basename;
if isfield(file_info, 'processingLog')
    log = file_info.processingLog;
    if iscell(log)
        collection(:).('processing_log') = cell2mat(file_info.processingLog);
    else
        collection(:).('processing_log') = file_info.processingLog;
    end
else
    collection(:).('processing_log') = ' ';
end
attr_values = {file_info.Attributes.Value}';
attr_keys = {file_info.Attributes.Name}';
for i = 1:size(attr_keys)
    value = attr_values{i};
    key = attr_keys{i};
    if iscell(value)
        value = cell2mat(value);
    end
    collection(:).(key) = value;
    collection(:).(key) = collection(:).(key);
end
collection(:).('input_names') = [attr_keys' 'collection_id'];
collection(:).('formatted_input_names') = collection.input_names;
dataset_keys = {file_info.Datasets.Name};
for i = 1:size(dataset_keys,2)
    key = dataset_keys{i};
    collection(:).(key) = h5read(path, ['/' key]);
    if key == 'x'
        collection(:).(key) = collection(:).(key)'; % for some reason, can't use &&
    elseif iscell(collection(:).(key))
        collection(:).(key) = collection(:).(key)';
    end
end
collection(:).('num_samples') = size(collection.Y, 2);
if isfield(collection, 'baseSampleId')
    collection(:).('base_sample_id') = collection.baseSampleId;
end
end