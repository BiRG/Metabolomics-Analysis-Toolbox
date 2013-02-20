function [sorted_fields_str,group_by_inxs,inxs,collection] = by_fields_listbox(collection,selected_fields)
% Return values useful in constructing the field values listbox below the "Group By", "Model by", etc list boxes.
%
% Note: all comments in this file were added after-the-fact by Eric Moyer
% based on his reading of the code and therefore may be a misinterpretation
% of the intention of the original author.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collection - A struct containing representing a spectral collection
%     object. Same format as one of the members of the cell arrayreturned 
%     by load_collections.m in common_scripts. 
%
% selected_fields - Cell array of string. List of the names of the fields
%     of the collection struct that were selected by the user. Each entry 
%     must be a field name so that collection.(entry) is valid.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% sorted_fields_str = Cell array of strings. The list of different values 
%     taken on by the ordered tuples of the selected fields. More 
%     precisely, The list of non-duplicate entries in collection.value in 
%     alphabetical order.
%
% group_by_inxs = Cell array of double vectors. group_by_inxs is the list
%     of sample indices which have the same values for the selected
%     indices.
%
%     Let values = sorted_fields_str(inxs). group_by_inxs{val_inx} is 
%     the list of all q such that collection.value{q} == values{val_inx}. 
%     In other words, the list of all indices into collection.value that 
%     have the same value as values{val_inx}
%
% inxs = Vector of double. inxs(i) is the index into sorted_fields_str 
%     where you can find the value shared by all the samples listed in 
%     group_by_inxs{i}. More precisely: sorted_fields_str(inxs(i)) contains
%     the common value of the samples for group_by_inxs{i}. Or, another way 
%     to say it, sorted_fields_str(inxs) is the non-duplicate entries in 
%     collection.value in the order they appear.
%
% collection - Struct. The input argument collection with a new field: 
%    'value' which represents the value of collection(i) projected onto the
%    selected fields. collection.value(i) is the concatenated string 
%    representations of the selected fields for the i'th measurement in the
%    collection. So, if collection.foo = [1,100,10,100,2] and
%    collection.bar = {'human','rat','rat','rat','human'} and selected
%    fields = {'foo','bar'} then collection.value = {'1, human', 
%    '100, rat', '10, rat', '100, rat','2, human'}
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
% >> c.foo=[1,100,10,100,2];
% >> c.bar={'human','rat','rat','rat','human'};
% >> c.baz=[1,2,3,4,5];
% >> [sorted_fields_str,group_by_inxs,inxs,collection]=by_fields_listbox(c, {'foo','bar'})
%
% sorted_fields_str = 
% 
%     '1, human'    '10, rat'    '100, rat'    '2, human'
% 
% 
% group_by_inxs = 
% 
%     [1]    [2, 4]    [3]    [5]
% 
% 
% inxs =
% 
%      1     3     2     4
% 
% 
% collection = 
% 
%       foo: [1 100 10 100 2]
%       bar: {'human'  'rat'  'rat'  'rat'  'human'}
%       baz: [1 2 3 4 5]
%     value: {'1, human'  '100, rat'  '10, rat'  '100, rat'  '2, human'}
%
%
% >> c.foo=[1,100,10,100,2];
% >> c.bar={'human','rat','rat','rat','human'};
% >> c.baz=[1,2,3,4,5];
% >> [sorted_fields_str,group_by_inxs,inxs,collection]=by_fields_listbox(c, {'foo','baz'})
%
%
% sorted_fields_str = 
% 
%     '1, 1'    '10, 3'    '100, 2'    '100, 4'    '2, 5'
% 
% 
% group_by_inxs = 
% 
%     [1]    [2]    [3]    [4]    [5]
% 
% 
% inxs =
% 
%      1     3     2     4     5
% 
% 
% collection = 
% 
%       foo: [1 100 10 100 2]
%       bar: {'human'  'rat'  'rat'  'rat'  'human'}
%       baz: [1 2 3 4 5]
%     value: {'1, 1'  '100, 2'  '10, 3'  '100, 4'  '2, 5'}
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Paul Anderson (before July 2011)
%
% Eric Moyer (February 2013) eric_moyer@yahoo.com
%

% Fill collection.value with a list of strings containing the projection
% of the samples onto the given fields. So, if field
% one contains 1,2,3 and field two contains 'human','rat','rat'. Then 
% collection.value will contain {'1,human','2,rat','3,rat'}
collection.value = {};
for k = 1:length(selected_fields)
    field = selected_fields{k};
    for i = 1:length(collection.(field))
        if k == 1
            collection.value{i} = '';
        else
            collection.value{i} = [collection.value{i},', '];
        end
        
        if iscell(collection.(field))
            if ischar(collection.(field){i})
                collection.value{i} = [collection.value{i},collection.(field){i}];
            else
                collection.value{i} = [collection.value{i},num2str(collection.(field){i})];
            end
        else
            collection.value{i} = [collection.value{i},num2str(collection.(field)(i))];
        end
    end
end

% Fill values and group_by_inxs.
%
% values = the list of non-duplicate entries in collection.value in the
%          order they appear
%
% group_by_inxs{val_inx} = the list of all q such that 
%       collection.value{q} == values{val_inx}. In other words, the list of
%       all indices into collection.value that have the same value as
%       values{val_inx}
values = {};
group_by_inxs = {};
for val_inx = 1:length(collection.value)
    v = collection.value{val_inx};
    found = false;
    for j = 1:length(values)
        if strcmp(values{j},v)
            found = true;
            group_by_inxs{j}(end+1) = val_inx;
            break;
        end
    end
    if ~found
        values{end+1} = v;
        group_by_inxs{end+1} = val_inx;
    end
end
[sorted_fields_str,inxs] = sort(values);
