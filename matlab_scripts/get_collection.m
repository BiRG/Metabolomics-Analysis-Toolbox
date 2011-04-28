function collection = get_collection(collection_id,username,password)
if ~exist('username') || ~exist('password')
%     username = getappdata(gcf,'username');
%     password = getappdata(gcf,'password');    
    username = [];
    password = [];
    if isempty(username) || isempty(password)
        [username,password] = logindlg;
%         setappdata(gcf,'username',username);
%         setappdata(gcf,'password',password);
    end
end
if ~exist('collection_id')
    prompt={'Collection ID:'};
    name='Enter the collection ID from the website';
    numlines=1;
    defaultanswer={''};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    collection_id = str2num(answer{1});
end

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

collection = load_collection(file,'');