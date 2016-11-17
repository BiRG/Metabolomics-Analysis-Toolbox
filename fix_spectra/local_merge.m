function local_merge
% Gets a local directory and collection ID from the user
% Merges all currently loaded collections into one collection
% Saves the combined collection to a file on the local machine
% Author: Oliver Ceccopieri

collections = getappdata(gcf,'collections');
suffix = getappdata(gcf,'suffix');

% Must have 2 or more collections loaded to merge
if length(collections) < 2
    msgbox('Only one collection is currently loaded');
end

% Get directory to store new merged file
indir = uigetdir;
if indir == 0
    msgbox(['Invalid directory ',indir]);
    return
end

% Get new collection ID from user
answer=inputdlg('Input new collection ID:', 'New Collection ID', 1);

% Set some new fields for the combined collection
combined_collection = collections{1};
combined_collection.filename = 'combined_collections';
combined_collection.collection_id = num2str(answer{1});

% Column-merge all vector fields for each loaded collection
for i = 2:length(collections)
    combined_collection.Y = [combined_collection.Y, collections{i}.Y];
    combined_collection.num_samples = combined_collection.num_samples + collections{i}.num_samples;
    combined_collection.base_sample_id = [combined_collection.base_sample_id, collections{i}.base_sample_id];
    combined_collection.time = [combined_collection.time, collections{i}.time];
    combined_collection.classification = [combined_collection.classification, collections{i}.classification];
    combined_collection.sample_id = [combined_collection.sample_id, collections{i}.sample_id];
    combined_collection.subject_id = [combined_collection.subject_id, collections{i}.subject_id];
    combined_collection.sample_description = [combined_collection.sample_description, collections{i}.sample_description];
    combined_collection.weight = [combined_collection.weight, collections{i}.weight];
    combined_collection.units_of_weight = [combined_collection.units_of_weight, collections{i}.units_of_weight];
    combined_collection.species = [combined_collection.species, collections{i}.species];
    combined_collection.original_multiplied_by = [combined_collection.original_multiplied_by, collections{i}.original_multiplied_by];
    combined_collection.Y_fixed = [combined_collection.Y_fixed, collections{i}.Y_fixed];
    combined_collection.Y_baseline = [combined_collection.Y_baseline, collections{i}.Y_baseline];
end

% Save final merged collection
save_collection(indir,suffix,combined_collection);
msgbox('Finished exporting merged collection');
