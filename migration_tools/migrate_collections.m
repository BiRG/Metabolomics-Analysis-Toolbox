function migrate_collections
%MIGRATE_COLLECTIONS Summary of this function goes here
%   Detailed explanation goes here
collections = get_old_collections;
for i = 1:length(collections)
    collections{i}.('name') = sprintf('%s (from %s)', collections{i}.description, collections{i}.collection_id);
end
post_collections('', collections);
end