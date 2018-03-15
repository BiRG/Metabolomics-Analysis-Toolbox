function [status, message] = authenticate(email, password)
if ~exist('email','var') || ~exist('password','var')
    [email,password] = logindlg;
    if isempty(email) && isempty(password)
        message = 'You must enter an email and password';
        status = 0;
        return;
    end
end
options = get_weboptions(email, password);
assignin('base', 'omics_weboptions', options);
message = '';
status = 1;
end