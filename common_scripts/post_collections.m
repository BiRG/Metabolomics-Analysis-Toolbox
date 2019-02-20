function post_collections(collections,suffix,analysis_id,email,password)
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

% Using the global-variable JWT 'session'

if ~is_authenticated()
    if exist('email', 'var') && exist('password', 'var')
        [auth_status, auth_msg] = authenticate(email, password);
    else
        [auth_status, auth_msg] = authenticate();
    end
    if ~auth_status
        fprintf('%s\n', auth_msg);
        return;
    end   
end
    
if ~exist('suffix', 'var')
    suffix = '';
end

if ~exist('analysis_id', 'var')
    prompt={'Analysis ID [leave blank to not attach]:'};
    title='Analysis ID';
    numlines=1;
    defaultanswer={''};
    answer=inputdlg(prompt,title,numlines,defaultanswer);
    if(isempty(answer))
        analysis_id = -1;
    else
        analysis_id = str2double(answer);
    end
end

for i = 1:length(collections)
    collection = collections{i};
    post_collection(collection, suffix, analysis_id);
end
