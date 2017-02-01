function [collection,message] = get_collection_sftp(collection_id,username,password,hostname)
% Gets the given collection from the birg website using the given username 
% and password.  If called without any of the parameters, displays dialogs
% to get them from the user.
%
% Returns the collection or {} on error.  If there is an error, message
% contains an error message for the user.
message = [];

if ~exist('username','var') || ~exist('password','var')
    [username,password] = logindlg;
    if isempty(username) && isempty(password)
        collection = {};
        message = 'You must enter a username and password';
        return;
    end
end
if ~exist('hostname', 'var')
    hostname = '130.108.28.148';
end
if ~exist('collection_id','var') || isempty(collection_id)
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
    collection_id = str2double(answer{1});
    if isnan(collection_id) || length(collection_id) ~= 1
        message = 'You must enter a number as the collection ID';
        collection = {};
        return;
    end
end

url = sprintf('http://birg.cs.wright.edu/omics_analysis/collections/%d.xml',collection_id);
try
    if exist('proxy.conf','file')
        load_proxy('proxy.conf');
    end
    %[xml, urlstatus] = webread(url, 'name', username, 'password', password);
    [xml,urlstatus] = urlread(url, 'Timeout', 360, 'get',{'name',username,'password',password, 'access', 'sftp'});
    if ~isempty(regexp(xml,'password', 'once'))
        message = 'Invalid password';
        collection = {};
        return;
    end
    if urlstatus == 0
        error('urlread failed with status 0: %s',url); %#ok<SPERR>
    end
catch ME
    disp(urlstatus);
    throw(ME);
end
n = regexp(xml,'<path>(.*)</path>','tokens');
path = n{1}{1};
n = regexp(path, '\/', 'split');
filename = n{size(n,2)};
remotepath = '/';
for i = 1:(size(n,2) - 1)
    remotepath = strcat(remotepath, n{i}, '/');
end
[sftpusername, sftppass] = logindlg('Title','Enter SSH Username/Password');
localdir = tempname
mkdir(localdir);
textdir=strcat(localdir, '/unzipped');
mkdir(textdir);
scp_simple_get(hostname, sftpusername, sftppass, filename, localdir, remotepath);
filename = strcat(localdir, '/', filename);
unzip(filename, textdir);
[~,basename,~]=fileparts(filename);
textfilename=strcat(textdir, '/', basename, '.txt');

collection = load_collection(textfilename, '');