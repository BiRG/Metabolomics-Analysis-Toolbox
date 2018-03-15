function [collections,message] = get_collections
% Displays dialogs for downloading collections from the BIRG server.  
% Returns a cell array of collections. On error returns an empty array.

if ~is_authenticated()
    authenticate();
end
% Read which collections to get
prompt={'Collection ID(s) [comma separated]:'};
name='Enter the collection ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if(isempty(answer))
    collections={};
    return;    
end
collection_ids = split(answer{1},',');

% Download collections
collections = {};
try
    for i = 1:length(collection_ids)
        collection_id = str2double(collection_ids{i});
        [collections{end+1}, message] = get_collection(collection_id);
    end
catch ME
    collections = {};
    if(regexp( ME.identifier,'MATLAB:websave'))
        msgbox(['Could not read a collection from BIRG server.\n' ...
            'Either the collection number was not valid or the server ' ...
            'is not working\n']);
    else
        fprintf(ME.message);
        fprintf('\n');
    end
end