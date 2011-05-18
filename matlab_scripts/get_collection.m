function [collection,message] = get_collection(collection_id,username,password)
message = [];

if ~exist('username') || ~exist('password')
    [username,password] = logindlg;
    if isempty(username) && isempty(password)
        collection = {};
        message = 'You must enter a username and password';
        return;
    end
end

if ~exist('collection_id') || isempty(collection_id)
    prompt={'Collection ID:'};
    name='Enter the collection ID from the website';
    numlines=1;
    defaultanswer={''};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    if isempty(answer)
        message = 'You must enter a collection ID';
        collection = {};
        return;
    end
    collection_id = str2num(answer{1});
end

url = sprintf('http://birg.cs.wright.edu/omics_analysis/collections/%d.xml',collection_id);
try
    [xml,status] = urlread(url,'get',{'name',username,'password',password});
    if ~isempty(regexp(xml,'password'))
        message = 'Invalid password';
        collection = {};
        return;
    end
    if status == 0
        error(sprintf('urlread failed with status 0: %s',url));
    end
catch ME
    status
    throw(ME);
end
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

collection = load_collection(file,'');