function collection = load_hdf5_collection(path)
file_info = h5info(path);
collection = struct;
collection(:).('filename') = file_info.Filename;
[~,basename,~] = fileparts(path);
collection(:).('collection_id') = basename;
if isfield(file_info, 'processingLog')
    log = file_info.processingLog;
    if iscell(log)
        collection(:).('processing_log') = cell2mat(log);
    else
        collection(:).('processing_log') = log;
    end
else
    collection(:).('processing_log') = ' ';
end
attr_values = {};
attr_keys = {};
if size(file_info.Attributes) 
    attr_values = {file_info.Attributes.Value}';
    attr_keys = {file_info.Attributes.Name}';
end
for i = 1:size(attr_keys)
    value = attr_values{i};
    key = attr_keys{i};
    if iscell(value)
        value = cell2mat(value);
    end
    collection(:).(key) = value;
    collection(:).(key) = collection(:).(key);
end

dataset_keys = {file_info.Datasets.Name};
for i = 1:size(dataset_keys,2)
    key = dataset_keys{i};
    collection(:).(key) = h5read(path, ['/' key]);
end
collection(:).('input_names') = [attr_keys' 'collection_id' dataset_keys];
collection(:).('formatted_input_names') = collection.input_names;
Y_size = size(collection.Y);
collection(:).('num_samples') = Y_size(Y_size~=max(size(collection.x)));
if isfield(collection, 'baseSampleId')
    collection(:).('base_sample_id') = collection.baseSampleId;
end
end