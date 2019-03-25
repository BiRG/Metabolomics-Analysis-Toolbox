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
req_body = struct('file', matlab.net.base64encode(data), 'name', collection.name, 'description', collection.processing_log, 'parent_id', collection.collection_id, 'analysis_id', analysis_id);
url = 'https://birg.cs.wright.edu/omics/api/collections/upload';
res = webwrite(url, req_body, omics_weboptions);
if isfield(res, 'id')
    new_id = res.id;
    message = sprintf('Created collection %d.', new_id);
    if (exist('analysis_id', 'var') && analysis_id ~= -1 && ~isnan(analysis_id))
        fprintf('Successfully posted collection %d and attached to analysis %d\n', new_id, analysis_id);
    else
        fprintf('Successfully posted collection %d. Not attached to analysis.\n', new_id);
    end    
else
    if isfield(res, 'message')
        message = res.message;
    else
        message = 'Upload Failed';
    end
    return;
end

end