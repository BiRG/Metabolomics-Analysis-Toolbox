function migrate_collections
%MIGRATE_COLLECTIONS Summary of this function goes here
%   Detailed explanation goes here
collections = get_old_collections;
for i = 1:length(collections)
    collections{i}.('name') = sprintf('%s (from %s)', collections{i}.description, collections{i}.collection_id);
    collections{i}.('userGroup') = '2';
    collections{i}.('groupPermissions') = 'full';
    collections{i}.('allPermissions') = 'readonly';
    collections{i}.('x') = collections{i}.('x')';
end
post_collections('', collections);
end