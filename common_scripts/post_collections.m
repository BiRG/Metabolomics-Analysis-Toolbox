function post_collections(main_h,collections,suffix,analysis_id,username,password)
% Ask for user information then post the given collections to the BIRG server
%
% Usage: post_collections(main_h,collections,suffix,analysis_id,username,password)
%
% The given collections are first saved to a temporary directory and then
% uploaded to BIRG.
%
% Code originally by Paul Anderson.  Comments added after-the-fact
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% main_h - ignored. Used in other functions as a handle to the main window
%
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

% Get the username and password from the user if not passed in as
% parameters. Exit without posting if the user cancels the dialog
if(~exist('username','var') || ~exist('password','var'))
    [username,password] = logindlg;
    if ~(ischar(username) && ischar(password))
        return;
    end
end

tmpdir = tempname;
mkdir(tmpdir);

for i = 1:length(collections)
    collection = collections{i};
    file = save_collection(tmpdir,suffix,collection);    
    url = sprintf('http://birg.cs.wright.edu/omics_analysis/spectra_collections.xml');
    xml = urlread(url,'post',{'name',username,'password',password,'analysis_id',num2str(analysis_id),'collection[data]',fileread(file)});
    delete(file);
    
    file = tempname;
    fid = fopen(file,'w');
    fprintf(fid,xml);
    fclose(fid);
    collection_xml = xml2struct(file);
    id = collection_xml.Children.Data;
    fprintf('Successfully posted collection %s-%s as collection %s\n',collection.collection_id, suffix, id);
    delete(file);
end
rmdir(tmpdir);
