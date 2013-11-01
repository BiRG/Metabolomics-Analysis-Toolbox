function [X,Y,available_X,available_Y,G,available_G] = get_run_data(hObject,handles) %#ok<INUSL>
try
    collection = handles.collection;
catch ME %#ok<NASGU>
    msgbox('Load a collection');
    return;
end

try
    are_groups = get(handles.groups_checkbox,'Value');
catch ME %#ok<NASGU>
    are_groups = true;
end

try
    group_by_inxs = handles.group_by_inxs;
catch ME %#ok<NASGU>
    group_by_inxs = [];
end

try
    model_by_inxs = handles.model_by_inxs;
    selected = get(handles.model_by_listbox,'Value');
    model_by_inxs = model_by_inxs(selected);
catch ME %#ok<NASGU>
    model_by_inxs = [];
end

try
    ignore_by_inxs = handles.ignore_by_inxs;
    selected = get(handles.ignore_by_listbox,'Value');
    ignore_by_inxs = ignore_by_inxs(selected);
catch ME %#ok<NASGU>
    ignore_by_inxs = [];
end

new_model_by_inxs = {};
for g = 1:length(model_by_inxs)    
    new_model_by_inxs{g} = []; %#ok<AGROW>
    for i = 1:length(model_by_inxs{g})
        ignore = false;
        inx_unpaired = model_by_inxs{g}(i);
        for ig = 1:length(ignore_by_inxs)
            for ii = 1:length(ignore_by_inxs{ig})
                iinx_unpaired = ignore_by_inxs{ig}(ii);
                if iinx_unpaired == inx_unpaired
                    ignore = true;
                    break;
                end
            end
        end
        if ~ignore
            new_model_by_inxs{g}(end+1) = inx_unpaired; %#ok<AGROW>
        end
    end
end
model_by_inxs = new_model_by_inxs;

% paired_by_inxs is a cell array of double vectors. paired_by_inxs{i}
% contains a list of the samples in the current collection that all have 
% the value specified by the i'th entry in the paired_by_listbox.
%
% The next code chooses only those indices that were selected. So that
% hereafter paired_by_inxs contains the list of samples which have one of
% values selected in the paired_by listbox when considering only the
% fields in the paired_by_fields listbox.
paired = false;
try
    paired_by_inxs = handles.paired_by_inxs;
    selected = get(handles.paired_by_listbox,'Value');
    paired_by_inxs = paired_by_inxs(selected); 
    paired = true;
catch ME %#ok<NASGU>
end

num_samples = 0;
for i = 1:length(model_by_inxs)
    num_samples = num_samples + length(model_by_inxs{i});
end
[num_variables,total_num_samples] = size(collection.Y);
   
% For OPLS (X and Y are switched, Y is now the labels)
if ~iscell(collection.Y)
    available_X = NaN*ones(num_variables,total_num_samples);
    X = [];%NaN*ones(num_variables,num_samples);
else
    available_X = cell(1,total_num_samples);
    X = {};
end
available_Y = NaN*ones(1,total_num_samples);
Y = [];%NaN*ones(1,num_samples);
available_G = NaN*ones(1,total_num_samples);
G = [];

s = 0;
if paired % Pair up the data
    fprintf('Starting pairing...\n');
    % Grap only those selected
    for g = 1:length(model_by_inxs)    
        for i = 1:length(model_by_inxs{g})
            inx_unpaired = model_by_inxs{g}(i);
            s = s + 1;
            % Now find matching subject ID
            %
            % The double loop just moves inx_paired through the flattened 
            % contents of paired_by_inxs once. It is equivalent to saying: 
            %
            % foreach inx_paired in flatten(paired_by_inxs)
            found = false;
            for p = 1:length(paired_by_inxs)
                for j = 1:length(paired_by_inxs{p})
                    inx_paired = paired_by_inxs{p}(j);

                    % Check for match - special-casing the situation where the ids are strings and
                    % where they are not
                    if iscell(collection.subject_id)
                        is_matching_id = strcmp(collection.subject_id{inx_paired}, ...
                            collection.subject_id{inx_unpaired}) && ...
                            inx_paired ~= inx_unpaired;
                    else
                        is_matching_id = ...
                            collection.subject_id(inx_paired) == collection.subject_id(inx_unpaired) && ...
                            inx_paired ~= inx_unpaired;
                    end

                    if is_matching_id
                        if ~iscell(X)
                            X(:,end+1) = collection.Y(:,inx_unpaired) - collection.Y(:,inx_paired); %#ok<AGROW>
                        else
                            X{end+1} = collection.Y{inx_unpaired} - collection.Y{inx_paired}; %#ok<AGROW>
                        end
                        G(end+1) = g;                             %#ok<AGROW>
                        if are_groups
                            Y(end+1) = g; %#ok<AGROW>
                        else
                            Y(end+1) = str2double(collection.value{inx_unpaired}) - str2double(collection.value{inx_paired}); %#ok<AGROW>
                        end
                        found = true;
                        break;
                    end
                end
            end
            if ~found
                fprintf('Could not find a match for sample with subject id %d at time %d classified as "%s"\n', ...
                    collection.subject_id(inx_unpaired), ...
                    collection.time(inx_unpaired), ...
                    collection.classification{inx_unpaired});
            end
        end
    end
    % Now grab all that is available
    for g = 1:length(group_by_inxs)
        for i = 1:length(group_by_inxs{g})
            inx_unpaired = group_by_inxs{g}(i);
            found = false;
            % Now find matching subject ID
            for p = 1:length(paired_by_inxs)
                for j = 1:length(paired_by_inxs{p})
                    inx_paired = paired_by_inxs{p}(j);
                    if collection.subject_id(inx_paired) == collection.subject_id(inx_unpaired) && inx_paired ~= inx_unpaired
                        if ~iscell(X)                        
                            available_X(:,inx_unpaired) = collection.Y(:,inx_unpaired) - collection.Y(:,inx_paired);
                        else
                            available_X{inx_unpaired} = collection.Y{inx_unpaired} - collection.Y{inx_paired};
                        end
                        available_G(inx_unpaired) = g;
                        if are_groups
                            available_Y(inx_unpaired) = g;
                        else
                            available_Y(inx_unpaired) = str2double(collection.value{inx_unpaired}) - str2double(collection.value{inx_paired});
                        end
                        found = true;
                        break;
                    end    
                end
                if found
                    break;
                end
            end
        end
    end
else
    for g = 1:length(model_by_inxs)    
        for i = 1:length(model_by_inxs{g})
            inx_unpaired = model_by_inxs{g}(i);
            s = s + 1;
            if iscell(X)                        
                X{s} = collection.Y{inx_unpaired}; %#ok<AGROW>
            else
                X(:,s) = collection.Y(:,inx_unpaired); %#ok<AGROW>
            end
            G(s) = g; %#ok<AGROW>
            if are_groups
                Y(s) = g; %#ok<AGROW>
            else
                Y(s) = str2double(collection.value{inx_unpaired}); %#ok<AGROW>
            end
        end
    end
    % Now grab all that is available
    for g = 1:length(group_by_inxs)
        for i = 1:length(group_by_inxs{g})
            inx_unpaired = group_by_inxs{g}(i);
            s = s + 1;            
            if ~iscell(X)                        
                available_X(:,inx_unpaired) = collection.Y(:,inx_unpaired);
            else
                available_X{inx_unpaired} = collection.Y{inx_unpaired};
            end
            available_G(inx_unpaired) = g;
            if are_groups
                available_Y(inx_unpaired) = g;
            else
                available_Y(inx_unpaired) = str2double(collection.value{inx_unpaired});
            end
        end
    end
end
