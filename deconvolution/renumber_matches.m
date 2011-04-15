function [reference,collection] = renumber_matches(reference,collection)
old_max_ids = reference.max_ids;
new_max_ids = NaN*old_max_ids;
cnt = 1;
for i = 1:length(new_max_ids)
    if isnan(new_max_ids(i)) % Make sure it hasn't already been set
        inxs = find(old_max_ids == old_max_ids(i));
        new_max_ids(inxs) = cnt;
        cnt = cnt + 1;
    end
end
inxs = find(isnan(new_max_ids));
new_max_ids(inxs) = 0;
reference.max_ids = new_max_ids;

if isfield(collection,'match_ids') && ~isempty(collection.match_ids)
    for s = 1:length(collection.match_ids)
        new_match_ids = 0*collection.match_ids{s};
        for i = 1:length(old_max_ids)
            old_max_id = old_max_ids(i);
            max_id = reference.max_ids(i);
            inxs = find(collection.match_ids{s} == old_max_id);
            new_match_ids(inxs) = max_id;
        end
        collection.match_ids{s} = new_match_ids;
    end
end
