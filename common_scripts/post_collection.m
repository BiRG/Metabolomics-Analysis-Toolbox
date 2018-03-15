function [message, new_id] = post_collection(collection, suffix, analysis_id, email, password)
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
file = save_collection(tempdir, suffix, collection);
fid = fopen(file, 'r');
data = fread(fid);
fclose(fid);
% matlab does not support multipart/form-data requests
% so we sadly have to base64 encode the file and send it as text...
req_body = struct('file', matlab.net.base64encode(data));
url = 'https://birg.cs.wright.edu/omics/api/collections/upload';
res = webwrite(url, req_body, omics_weboptions);
if isfield(res, 'id')
    new_id = res.id;
    message = 'OK';
else
    if isfield(res, 'message')
        message = res.message;
    else
        message = 'Upload Failed';
    end
    return;
end
attach_url = sprintf('https://birg.cs.wright.edu/analyses/attach/%d', analysis_id);
attach_data = struct('collectionId', new_id);
omics_weboptions.MediaType = 'application/json';
attach_res = webwrite(attach_url, attach_data, omics_weboptions);
message = [message ' ' attach_res.message];
fprintf('Successfully posted collection %d and attached to analysis %d', new_id, analysis_id);