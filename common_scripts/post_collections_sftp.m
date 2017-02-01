function post_collections_sftp(collections,analysis_id,username,password,timeout, hostname)
% Ask for user information then post the given collections to the BIRG server
%
% Usage: post_collections_sftp(main_h,collections,suffix,analysis_id,username,password)
%
% The given collections are first saved to a temporary directory and then
% uploaded to BIRG.
%
% Code originally by Paul Anderson.  Comments added after-the-fact
%
% Modified by Daniel Foose
% This actually uses SCP instead of sftp.
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% collections - (cell array) a cell array of spectral collections. Each
%     spectral collection is a struct of spectra. This is the format of
%     the return value of load_collections.m in common_scripts.
%
% suffix - (string) a suffix appended to the collection number when it is
%     saved in the temp directory
%
% analysis_id - (scalar) the id of the analysis to which the uploaded
%     collections will be added
%
% username - (optional string) if either username or password is absent,
%     then the user will be prompted for it
%
% password - (optional string) Ibid
%
% timeout - (optional scalar) Length of timeout in seconds. If unspecified,
%     default timeout will be used.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% None
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Paul Anderson (Before July 2011)
%
% Eric Moyer (July 2013) eric_moyer@yahoo.com
%
% Dan C. Wlodarski (April 2015) dan.wlodarski@gmail.com

% Get the username and password from the user if not passed in as
% parameters. Exit without posting if the user cancels the dialog
if(~exist('username','var') || ~exist('password','var'))
    [username,password] = logindlg;
    if ~(ischar(username) && ischar(password))
        return;
    end
end
if (~exist('hostname','var'))
    hostname='130.108.28.148';
end

tmpdir = tempname;
mkdir(tmpdir);

[sftpusername, sftppass] = logindlg('Title','Enter SSH Username/Password');
for i = 1:length(collections)
    collection = collections{i};
    [~,tmpname,~]=fileparts(tmpdir);
    archivepath=strcat(tmpdir, '/', tmpname, '.zip');
    archivename=strcat(tmpname, '.zip');
    textpath=strcat(tmpdir, '/', tmpname, '.txt');
    file = save_collection(textpath, collection);
    zip(archivepath, file);
    url = sprintf('http://birg.cs.wright.edu/omics_analysis/spectra_collections.xml');
    scp_simple_put(hostname, sftpusername, sftppass, archivename, '/sftpjail', tmpdir, archivename);
    if (exist('timeout','var'))
        if (~isnumeric(timeout))
            timeout = str2double(timeout);
        end
    else
        timeout = 360;
    end
    if (~isnan(timeout))
        urlread(url,'post',...
            {'name',username,'password',password,'analysis_id',num2str(analysis_id), 'filename', archivename},...
            'Timeout',timeout);
    else
        urlread(url,'post',...
            {'name',username,'password',password,'analysis_id',num2str(analysis_id),'filename', archivename});
    end
    delete(file);
end
