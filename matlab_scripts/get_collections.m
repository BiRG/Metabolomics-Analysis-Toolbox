function collections = get_collections
username = getappdata(gcf,'username');
password = getappdata(gcf,'password');    
if isempty(username) || isempty(password)
    [username,password] = logindlg;
    setappdata(gcf,'username',username);
    setappdata(gcf,'password',password);
end

%Throw an exception if no username or password were entered
if isempty(username) || isempty(password)
    exception = MException('get_collections:no_collections', ...
        ['User cancelled without entering a user-name or password' ...
        'to log in for getting a collection']);
    throw(exception);
end
    
% Read which collections to get
prompt={'Collection ID(s) [comma separated]:'};
name='Enter the collection ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
if(isempty(answer))
    exception = MException('get_collections:no_collections', ...
        'User did not enter a list of collections to get.');
    throw(exception);    
end
collection_ids = split(answer{1},',');

% Download collections
collections = {};
xml = '';
try
    for i = 1:length(collection_ids)
        collection_id = str2num(collection_ids{i});

        url = sprintf('http://birg.cs.wright.edu/omics_analysis/collections/%d.xml',collection_id);
        xml = urlread(url,'get',{'name',username,'password',password});
        file = tempname;
        fid = fopen(file,'w');
        fwrite(fid,xml);
        %fprintf(fid,xml);
        fclose(fid);
        collection_xml = xml2struct(file);
        data = collection_xml.Children(2).Children.Data;
        file = tempname;
        fid = fopen(file,'w');
        fwrite(fid,data);
        %fprintf(fid,data);
        fclose(fid);

        collections{end+1} = load_collection(file,'');
    end
catch ME
    if(regexp( ME.identifier,'MATLAB:urlread'))
        fprintf(['Could not read a collection from BIRG server.\n' ...
            'Either the collection number was not valid or the server ' ...
            'is not working\n']);
        collections = {};
    else
        fprintf('Failed with following xml:\n');
        fprintf(xml);
        fprintf('\n');
    end
end


if(isempty(collections))
    exception = MException('get_collections:no_collections', ...
        ['The entered list of collections could be retrieved - either ' ... 
        'because of invalid elements or because of server ' ... 
        'communication errors.']);
    throw(exception);
end    
