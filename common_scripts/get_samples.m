function [samples,message] = get_samples
% Displays dialogs for downloading collections from the BIRG server.  
% Returns a cell array of collections. On error returns an empty array.

if ~is_authenticated()
    authenticate();
end
% Read which collections to get
prompt={'Sample ID(s) [comma separated]:'};
name='Enter the sample ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if(isempty(answer))
    samples={};
    return;    
end
sample_ids = split(answer{1},',');

% Download collections
samples = {};
try
    for i = 1:length(sample_ids)
        collection_id = str2double(sample_ids{i});
        [samples{end+1}, message] = get_sample(collection_id);
    end
catch ME
    samples = {};
    if(regexp( ME.identifier,'MATLAB:websave'))
        msgbox(['Could not read a collection from BIRG server.\n' ...
            'Either the collection number was not valid or the server ' ...
            'is not working\n']);
    else
        fprintf(ME.message);
        fprintf('\n');
    end
end