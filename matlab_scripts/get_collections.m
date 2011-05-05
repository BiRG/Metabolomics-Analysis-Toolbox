function collections = get_collections
% Displays dialogs for downloading collections from the BIRG server.  
% Returns a cell array of collections. On error returns an empty array.

% username = getappdata(gcf,'username');
% password = getappdata(gcf,'password');    
% if isempty(username) || isempty(password)
    [username,password] = logindlg;
%     setappdata(gcf,'username',username);
%     setappdata(gcf,'password',password);
% end

%Return empty collection username and password were not entered
if isempty(username) || isempty(password)
    collections={};
    return;
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
xml = '';
try
    for i = 1:length(collection_ids)
        collection_id = str2num(collection_ids{i});

        url = sprintf('http://birg.cs.wright.edu/omics_analysis/collections/%d.xml',collection_id);
        xml = urlread(url,'get',{'name',username,'password',password});
        n = regexp(xml,'<data>(.*)</data>','tokens');
        data = n{1}{1};
        % file = tempname;
        % fid = fopen(file,'w');
        % fwrite(fid,xml);
        % %fprintf(fid,xml);
        % fclose(fid);
        % collection_xml = xml2struct(file);
        % data = collection_xml.Children(2).Children.Data;
        file = tempname;
        fid = fopen(file,'w');
        fwrite(fid,data);
        %fprintf(fid,data);
        fclose(fid);

        collections{end+1} = load_collection(file,'');
        
    end
catch ME
    collections = {};
    if(regexp( ME.identifier,'MATLAB:urlread'))
        fprintf(['Could not read a collection from BIRG server.\n' ...
            'Either the collection number was not valid or the server ' ...
            'is not working\n']);
    else
        fprintf('Get Collections failed with following xml:\n');
        fprintf(xml);
        fprintf('\n');
    end
end
