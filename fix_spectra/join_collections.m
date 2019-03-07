function new_collection = join_collections(collections, ...
    pos_label, neg_label, pos_value, neg_value, join_label)
% Create a collection by horizontally concatenating multiple collections or
% files from the same collection. One set of collections will have their
% values reflected across the y-axis to allow for both kinds of spectra to
% exist on the same axis
%
% The initial concatenation is analgous to a relational database join:
% SELECT * 
% FROM collection1 
% INNER JOIN collection2 
% ON collection1.join_label=collection2.join_label;
%
% Where collection1 is assigned "negative" and collection2 assigned to
% "positive" (collection1 and collection2 can both come from more than one
% collection).
%
% The collections are assigned to be either "positive" or "negative" based on 
% the values of pos_value and neg value:
% A spectrum s is positive iff:
% s.pos_label == pos_value
% And negative iff:
% s.neg_label == neg_value
%
% The positive values are joined to the negative values for every
% particular value of target_value
%
% If both conditions are true for any particular spectrum, an error will
% be thrown and the new_collection will not be created.
%
% collections is a cell array containing collections. There must be only 2!
% pos_label is the label for spectra which will be on the LHS of the 
%           resulting spectra
% neg_label is the label for spectra which will be on the RHS of the
%           resulting spectra
% pos_value is the value associated with the spectra which will be on the
%           LHS of the resulting spectra
% neg_value is the value associated with the spectra which will be on the
%           RHS of the resulting spectra
% join_label is the value(s) on which to join the two "positive" and
%           "negative" values. The join_label can be a combination of
%           multiple values that all have to be equal and are unique to one
%           record (i.e. {'subject_id', 'time'})

    %  find values meeting conditions and concatenate them
    if nargin < 1
        error('No collections specified!')
    elseif nargin < 6
        params = join_parameter_dialog(collections);
        pos_label = params.pos_label;
        neg_label = params.neg_label;
        pos_value = params.pos_value;
        neg_value = params.neg_value;
        join_label = {params.join_label};
    end
    
    if length(collections) ~= 2
        error(['Join operation is only supported for 2 collections at a time.' ...
        'Please concatenate collections with the same values'])
    end

    for c = 1:length(collections)
        positive_indices = find_columns(collections{c}.(pos_label), pos_value);
        negative_indices = find_columns(collections{c}.(neg_label), neg_value);
        if ~isempty(intersect(positive_indices, negative_indices))
            error('Invalid positive or negative condition specified! Positive and negative indices overlap!')
        end
        if isempty(negative_indices) && isempty(positive_indices)
            error("Collection %d is not a valid join target (both positive and negative labels do not exist)", collections{c}.collection_id);
        end
        if ~isempty(positive_indices)
            if exist('positive_collection', 'var')
                error('LHS and RHS should be in separate collections!');
            end
        
            positive_collection = collections{c};
            spectrum_count = size(positive_collection.Y, 2);
            positive_collection.Y = positive_collection.Y(:, positive_indices);
        
            % remove negative values of x
            good_inds = find(positive_collection.x > 0);
            positive_collection.Y = positive_collection.Y(good_inds',:);
            positive_collection.x = positive_collection.x(good_inds); % one is transposed for some historical reason
        
            for f = 1:length(positive_collection.input_names)
                input_name = positive_collection.input_names{f};
                if size(positive_collection.(input_name), 2) == spectrum_count
                    positive_collection.(input_name) = positive_collection.(input_name)(:,positive_indices);
                end
            end
        end
    
        if ~isempty(negative_indices)
            if exist('negative_collection', 'var')
                error('LHS and RHS should be in separate collections!');
            end
        
            negative_collection = collections{c};
            spectrum_count = size(negative_collection.Y, 2);
            negative_collection.Y = negative_collection.Y(:,negative_indices);
        
            % remove negative values of x
            good_inds = find(negative_collection.x > 0);
            negative_collection.Y = negative_collection.Y(good_inds',:);
            negative_collection.x = -1 * negative_collection.x(good_inds); % one is transposed for some historical reason
        
            for f = 1:length(negative_collection.input_names)
                input_name = negative_collection.input_names{f};
                if size(negative_collection.(input_name), 2) == spectrum_count
                    negative_collection.(input_name) = negative_collection.(input_name)(:,negative_indices);
                end
            end
        end
    end
    
    % do the join
    % find unique pairs in the join attributes
    % we do this by just cramming their values together in a cell array
    if iscell(join_label)
        join_label_count = length(join_label);
    else
        join_label_count = 1;
    end
    positive_label = cell(1, size(positive_collection.Y, 2));
    negative_label = cell(1, size(negative_collection.Y, 2));
    for li = 1:join_label_count
        if iscell(join_label)
            label = join_label{li};
        else
            label = join_label;
        end
        positive_label = strcat(positive_label, convert_to_cell(positive_collection.(label)));
        negative_label = strcat(negative_label, convert_to_cell(negative_collection.(label)));
    end
    % ensure that negative and positive labels are unique %
    if (length(positive_label) ~= length(unique(positive_label))) ...
            || (length(negative_label) ~= length(unique(negative_label)))
        error('Values on join condition are not unique!')
    end
    % for every value on the positive collection, find corresponding on
    % negative collection and vertcat them
    common_label = intersect(positive_label, negative_label);
    % delete rows from two collections that are not in the intersection
    good_inds = find(ismember(positive_label, common_label));
    % only keep common columns
    % sort labels and get sort indices
    [~, sort_inds] = sort(positive_label(good_inds)); % sort_inds refer to only subset of negative_label
    spectrum_count = size(positive_collection.Y, 2);
    for f = 1:length(positive_collection.input_names)
        input_name = positive_collection.input_names{f};
        if size(positive_collection.(input_name), 2) == spectrum_count
            positive_collection.(input_name) = positive_collection.(input_name)(:,good_inds);
            positive_collection.(input_name) = positive_collection.(input_name)(:,sort_inds);
        end
    end   
    good_inds = find(ismember(negative_label, common_label));
    [~, sort_inds] = sort(negative_label(good_inds));
    % only keep common columns
    spectrum_count = size(negative_collection.Y, 2);
    for f = 1:length(negative_collection.input_names)
        input_name = negative_collection.input_names{f};
        if size(negative_collection.(input_name), 2) == spectrum_count
            negative_collection.(input_name) = negative_collection.(input_name)(:, good_inds);
            negative_collection.(input_name) = negative_collection.(input_name)(:, sort_inds);
        end
    end
    % perform the actual concatenation:
    positive_collection.Y = vertcat(negative_collection.Y, positive_collection.Y);
    positive_collection.x = horzcat(negative_collection.x, positive_collection.x);
    join_label_desc = strjoin(join_label, ',');
    positive_collection.name = sprintf('Collection %s join Collection %s on (%s)', positive_collection.collection_id, negative_collection.collection_id, join_label_desc);
    positive_collection.processing_log = sprintf('%s Joined Collection %s and Collection %s on (%s).', positive_collection.processing_log, positive_collection.collection_id, negative_collection.collection_id, join_label_desc);
    % remove the label, keep join labels
    new_collection = rmfield(positive_collection, pos_label);
    new_collection.(sprintf('positive_%s', pos_label)) = pos_value;
    new_collection.(sprintf('negative_%s', neg_label)) = neg_value;
end

function ind = find_columns(arr, val)
    ind = strfind(arr, val);
    if iscell(ind)
        ind = find(~cellfun(@isempty,ind));
    end
end

function converted = convert_to_cell(input)
    if isnumeric(input)
        converted = cellfun(@(v){num2str(v(1))}, num2cell(input));
    else
        converted = input;
    end
end