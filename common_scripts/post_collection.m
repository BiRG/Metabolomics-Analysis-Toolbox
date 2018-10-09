function [message, new_id] = post_collection(collection, suffix, analysis_id, email, password)
% Upload a collection structure as an HDF5 file to Omics Dashboard
if ~exist('suffix', 'var')
    suffix = '';
end
new_id = NaN;
if ~is_authenticated()
    if exist('email', 'var') && exist('password', 'var')
        [auth_status, auth_msg] = authenticate(email, password);
    else
        [auth_status, auth_msg] = authenticate();
    end
    if ~auth_status
        message = auth_msg;
        return;
    end   
end
if ~isfield(collection, 'groupPermissions')
    collection.('groupPermissions') = 'full';
end
if ~isfield(collection, 'allPermissions')
    collection.('allPermissions') = 'readonly';
end
if ~isfield(collection, 'userGroup')
    collection.('userGroup') = -1;
end
if ~isfield(collection, 'name')
    if isfield(collection, 'description')
        collection.('name') = collection.description;
    else
        collection.('name') = 'No Name Provided';
    end
end
if ~isfield(collection, 'description')
    collection.('description') = 'No description provided';
end
omics_weboptions = evalin('base', 'omics_weboptions');
% file upload routes take multipart/form-data instead of JSON
outdir = tempname;
mkdir(outdir);
collection = convert_to_new_format(collection);
filename = save_collection(outdir, suffix, collection);
fid = fopen(filename, 'r');
data = fread(fid);
fclose(fid);
% once data is read, we can delete the file
try
    rmdir(outdir)
catch
    fprintf('No directories were removed\n');
end
% matlab does not support multipart/form-data requests
% so we sadly have to base64 encode the file and send it as text...
req_body = struct('file', matlab.net.base64encode(data));
url = 'https://birg.cs.wright.edu/omics/api/collections/upload';
res = webwrite(url, req_body, omics_weboptions);
if isfield(res, 'id')
    new_id = res.id;
    message = sprintf('Created collection %d.', new_id);
else
    if isfield(res, 'message')
        message = res.message;
    else
        message = 'Upload Failed';
    end
    return;
end
if (exist('analysis_id', 'var') && analysis_id ~= -1 && ~isnan(analysis_id))
    attach_url = sprintf('https://birg.cs.wright.edu/omics/api/analyses/attach/%d', analysis_id);
    attach_data = struct('collectionId', new_id);
    omics_weboptions.MediaType = 'application/json';
    attach_res = webwrite(attach_url, attach_data, omics_weboptions);
    message = [message ' ' attach_res.message '.'];
    fprintf('Successfully posted collection %d and attached to analysis %d\n', new_id, analysis_id);
else
    fprintf('Successfully posted collection %d. Not attached to analysis.\n', new_id);

end