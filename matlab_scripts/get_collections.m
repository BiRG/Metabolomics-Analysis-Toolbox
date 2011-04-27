function collections = get_collections
username = getappdata(gcf,'username');
password = getappdata(gcf,'password');    
if isempty(username) || isempty(password)
    [username,password] = logindlg;
    setappdata(gcf,'username',username);
    setappdata(gcf,'password',password);
end

% Read which collections to get
prompt={'Collection ID(s) [comma separated]:'};
name='Enter the collection ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
collection_ids = split(answer{1},',');


% Download collections
collections = {};
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
    fprintf('Failed with following xml:\n');
    fprintf(xml);
    fprintf('\n');    
end
