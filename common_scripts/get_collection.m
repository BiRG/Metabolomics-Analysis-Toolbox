function [collection,message] = get_collection(collection_id,email,password)
% Gets the given collection from the birg website using the given username 
% and password.  If called without any of the parameters, displays dialogs
% to get them from the user.
%
% Returns the collection or {} on error.  If there is an error, message
% contains an error message for the user.
message = '';
collection = struct;


if ~is_authenticated()
    if exist('email', 'var') && exist('password', 'var')
        [auth_status, auth_msg] = authenticate(email, password);
    else
        [auth_status, auth_msg] = authenticate();
    end
    if ~auth_status
        collection = {};
        message = auth_msg;
        return;
    end   
end
omics_weboptions = evalin('base', 'omics_weboptions');

if ~exist('collection_id','var') || isempty(collection_id)
    prompt={'Collection ID:'};
    name='Enter the collection ID from the website';
    numlines=1;
    defaultanswer={''};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    if isempty(answer)
        message = 'You must enter a collection ID';
        return;
    end
    collection_id = str2double(answer{1});
    if isnan(collection_id) || length(collection_id) ~= 1
        message = 'You must enter a number as the collection ID';
        return;
    end
end
download_url = sprintf('https://birg.cs.wright.edu/omics/api/collections/download/%d', collection_id);
info_url = sprintf('https://birg.cs.wright.edu/omics/api/collections/%d', collection_id);

h5_filename = sprintf('%s%d.h5', tempdir, collection_id);
% TODO: get name from server and insert into file
h5_filename = websave(h5_filename, download_url, omics_weboptions);
info_response = webread(info_url, omics_weboptions);
collection = load_hdf5_collection(h5_filename);
collection = convert_to_old_format(collection);
collection.('name') = info_response.name;
end