function [X,Y,available_X,available_Y] = get_run_data(hObject,handles)
try
    collection = handles.collection;
catch ME
    msgbox('Load a collection');
    return;
end

try
    group_by_inxs = handles.group_by_inxs;
    selected = get(handles.group_by_listbox,'Value');
    group_by_inxs = {group_by_inxs{selected}};
catch ME
    msgbox('Select groups');
    return;
end

try
    model_by_inxs = handles.model_by_inxs;
    selected = get(handles.model_by_listbox,'Value');
    model_by_inxs = {model_by_inxs{selected}};
catch ME
    msgbox('Select models');
    return;
end

paired = false;
try
    paired_by_inxs = handles.paired_by_inxs;
    selected = get(handles.paired_by_listbox,'Value');
    paired_by_inxs = {paired_by_inxs{selected}};
    paired = true;
catch ME
end

num_samples = 0;
for i = 1:length(model_by_inxs)
    num_samples = num_samples + length(model_by_inxs{i});
end
[num_variables,total_num_samples] = size(collection.Y);
   
% For OPLS (X and Y are switched, Y is now the labels)
available_Y = NaN*ones(1,total_num_samples);
available_X = NaN*ones(num_variables,total_num_samples);
Y = [];%NaN*ones(1,num_samples);
X = [];%NaN*ones(num_variables,num_samples);
s = 0;
if paired % Pair up the data
    fprintf('Starting pairing...\n');
    % Grap only those selected
    for g = 1:length(model_by_inxs)    
        for i = 1:length(model_by_inxs{g})
            inx_unpaired = model_by_inxs{g}(i);
            s = s + 1;
            % Now find matching subject ID
            found = false;
            for p = 1:length(paired_by_inxs)
                for j = 1:length(paired_by_inxs{p})
                    inx_paired = paired_by_inxs{p}(j);
                    if collection.subject_id(inx_paired) == collection.subject_id(inx_unpaired) && inx_paired ~= inx_unpaired
%                         inxs_pairing1(end+1,:) = [inx_unpaired,inx_paired];
                        X(:,end+1) = collection.Y(:,inx_unpaired) - collection.Y(:,inx_paired);
                        Y(end+1) = g;
                        found = true;
                        break;
                    end
                end
            end
            if ~found
                fprintf('Could not match sample %d at time %d with classification %s\n',collection.subject_id(inx_unpaired),collection.time(inx_unpaired),collection.classification{inx_unpaired});
            end
        end
    end
    % Now grab all that is available
    for g = 1:length(handles.group_by_inxs)
        for i = 1:length(handles.group_by_inxs{g})
            inx_unpaired = handles.group_by_inxs{g}(i);
            found = false;
            % Now find matching subject ID
            for p = 1:length(paired_by_inxs)
                for j = 1:length(paired_by_inxs{p})
                    inx_paired = paired_by_inxs{p}(j);
                    if collection.subject_id(inx_paired) == collection.subject_id(inx_unpaired) && inx_paired ~= inx_unpaired
%                         inxs_pairing1(end+1,:) = [inx_unpaired,inx_paired];
                        available_X(:,inx_unpaired) = collection.Y(:,inx_unpaired) - collection.Y(:,inx_paired);
                        available_Y(inx_unpaired) = g;
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
            X(:,s) = collection.Y(:,inx_unpaired);
            Y(s) = g;
        end
    end
    % Now grab all that is available
    for g = 1:length(handles.group_by_inxs)
        for i = 1:length(handles.group_by_inxs{g})
            inx_unpaired = handles.group_by_inxs{g}(i);
            s = s + 1;
            available_X(:,inx_unpaired) = collection.Y(:,inx_unpaired);
            available_Y(inx_unpaired) = g;
        end
    end
end