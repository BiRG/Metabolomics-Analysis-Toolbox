function combined_collection = merge_collections(collections)
% Merge collections into one collection
% Authors: Oliver Ceccopieri, Daniel Foose
% Must have 2 or more collections loaded to merge
if length(collections) < 2
    msgbox('Only one collection is currently loaded');
end

% Get new collection ID from user
answer=inputdlg('Input new collection Name:', 'New Collection Name', 1, {collections{1}.name});

% Set some new fields for the combined collection
combined_collection = collections{1};
combined_collection.name = num2str(answer{1});
combined_collection.collection_id = 0;

reserved_names = {'name', 'x', 'input_names', 'formatted_input_names', ...
    'collection_id', 'type', 'description', 'processing_log', 'filename', ...
    'num_samples', 'groupPermissions', 'allPermissions', 'userGroup'};
names = fieldnames(combined_collection);
use_name = ones(size(names));
for i = 1:length(names)
    if ismember(names{i}, reserved_names)
        use_name(i) = 0;
    else
        for j = 2:length(collections)
            if ~ismember(names{i}, fieldnames(collections{j}))
                use_name(i) = 0;
                break;
            end
        end             
    end
end

for i = 2:length(collections)
    for j = 1:length(names)
        if use_name(j) == 1
            if ~isnumeric(collections{1}.(names{j}))
                if ~iscell(combined_collection.(names{j}))
                    combined_collection.(names{j}) = {combined_collection.(names{j})};
                end
                if ~iscell(collections{i}.(names{j}))
                    collections{i}.(names{j}) = {collections{i}.(names{j})};
                end
            end
            combined_collection.(names{j}) = [combined_collection.(names{j}) collections{i}.(names{j})];
        end
    end
end