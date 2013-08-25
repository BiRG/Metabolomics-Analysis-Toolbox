function merge_processing_logs
% Displays dialogs for merging collection processing logs on the BIRG server.  
% 
% Queries the user for authentication data, collecitons to merge, and the
% analysis where to put them.
%
% Then uploads new copies of all the collections. Each copy has the same 
% processing log as the log for the new copy of the first collection.

[username,password] = logindlg;

%Do nothing if username and password were not entered
if isempty(username) || isempty(password)
    return;
end
    
% Read which collections to get - do nothing if no collections
prompt={'Collection ID(s) to merge (will not be loaded into fix_spectra) [comma separated]:'};
name='Enter the collection IDs from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if(isempty(answer))
    return;    
end
collection_ids = split(answer{1},',');

% Ensure the list is not empty
if length(collection_ids) < 1
    return;
end

% Convert the ids to numbers
cids = zeros(size(collection_ids));
for i = 1:length(collection_ids)
    cids(i) = str2double(collection_ids{i});
end
collection_ids = cids;

% Read analysis id where combined collections will be put
prompt={'Analysis ID:'};
name='Enter analysis ID where the combined collections will be put';
answer=inputdlg(prompt,name,numlines,defaultanswer);
if(isempty(answer))
    return;    
end
analysis_id = str2double(answer{1});


% Download collections and re-upload them with the new processing log
xml = '';
% try
    new_log = 1;
    wait_h = waitbar(0, sprintf('Combined %d of %d collections. Working on %d', 0, length(collection_ids), collection_ids(1)));
    num_ids = length(collection_ids);
    for i = 1:num_ids
        waitbar((i-1)/num_ids, wait_h, sprintf(['Combined %d of %d '...
            'collections. Working on %d'], i-1, num_ids, ...
            collection_ids(i)));
        
        collection_id = collection_ids(i);        
        
        [collection,message] = get_collection(collection_id,username,password);
        if ~isempty(message)
            return;
        end
        if ~ischar(new_log)
            new_log = [collection.processing_log ' Combined different processing logs, making all look like this one.'];
        end
        collection.processing_log = new_log;
        
        post_collections(gcf,{collection},'combine_collections',analysis_id,username,password);
    end
    close(wait_h);
% catch ME
%     if(regexp( ME.identifier,'MATLAB:urlread'))
%         msgbox(['Could not read a collection from/ write it to BIRG server.\n' ...
%             'Either the collection number was not valid or the server ' ...
%             'is not working\nIt is possible some collections were merged and not others.']);
%     else
%         fprintf(ME.message);
%         fprintf('\n');
%         fprintf('Get Collections failed with following xml:\n');
%         fprintf(xml);
%         fprintf('\n');
%     end
% end
