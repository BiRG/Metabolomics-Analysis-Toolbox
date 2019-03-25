function [sample,message] = get_sample(sample_id,email,password)
% Gets the given collection from the birg website using the given username 
% and password.  If called without any of the parameters, displays dialogs
% to get them from the user.
%
% Returns the collection or {} on error.  If there is an error, message
% contains an error message for the user.
message = '';
sample = struct;


if ~is_authenticated()
    if exist('email', 'var') && exist('password', 'var')
        [auth_status, auth_msg] = authenticate(email, password);
    else
        [auth_status, auth_msg] = authenticate();
    end
    if ~auth_status
        sample = {};
        message = auth_msg;
        return;
    end   
end
omics_weboptions = evalin('base', 'omics_weboptions');

if ~exist('sample_id','var') || isempty(sample_id)
    prompt={'Sample ID:'};
    name='Enter the collection ID from the website';
    numlines=1;
    defaultanswer={''};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    if isempty(answer)
        message = 'You must enter a collection ID';
        return;
    end
    sample_id = str2double(answer{1});
    if isnan(sample_id) || length(sample_id) ~= 1
        message = 'You must enter a number as the collection ID';
        return;
    end
end
download_url = sprintf('https://birg.cs.wright.edu/omics/api/samples/download/%d', sample_id);
info_url = sprintf('https://birg.cs.wright.edu/omics/api/samples/%d', sample_id);

h5_filename = sprintf('%s%d.h5', tempdir, sample_id);
% TODO: get name from server and insert into file
h5_filename = websave(h5_filename, download_url, omics_weboptions);
info_response = webread(info_url, omics_weboptions);
sample = load_hdf5_collection(h5_filename);
sample = convert_to_old_format(sample);
sample.('name') = info_response.name;
end