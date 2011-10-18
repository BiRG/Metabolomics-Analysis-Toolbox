function send_email_from_birg_autobug(recipients, subject, message, attachments)
%send_email_from_birg_autobug Sends an email (like sendmail) from birg_autobug@gmail.com
%   Temporarily sets user preferences to send emails using
%   birg_autobug@gmail.com then sets them back.  Parameters are passed
%   directly to SENDMAIL -- see there for explanations
% 
%   All the forms listed in SENDMAIL are available here:
%
%   send_email_from_birg_autobug(recipients, subject)
%   send_email_from_birg_autobug(recipients, subject, message)
%   send_email_from_birg_autobug(recipients, subject, message, attachments)
%
%   Having this file is a bit of a security risk since theoretically, a
%   spammer could get a hold of it and send email from BIRG Autobug.
%
% See also SENDMAIL

%Set preferences releated to email saving current values
preffield = {'E_mail', 'SMTP_Username', 'SMTP_Password', 'SMTP_Server'};
newpref = {'birg.autobug@gmail.com','birg.autobug@gmail.com', ...
    'CSSXDW9CnPHX', 'smtp.gmail.com'};
for i = 1:4
    if ispref('Internet', preffield{i})
        oldprefs.(preffield{i})=getpref('Internet',preffield{i});
    end
    setpref('Internet', preffield{i},newpref{i});
end


%Set java properties releated to email saving current values
props = java.lang.System.getProperties;
propfield = {'mail.smtp.auth', 'mail.smtp.socketFactory.class', ...
    'mail.smtp.socketFactory.port'};
newprop = {'true', 'javax.net.ssl.SSLSocketFactory', '465'};
oldprops_values = cell(1,3);
oldprops_existed = zeros(1,3);
for i = 1:3
    if props.containsKey(propfield{i})
        oldprops_existed(i) = 1;
        oldprops_values{i} = props.getProperty(propfield{i});
    end
    props.setProperty(propfield{i}, newprop{i});
end

%Depending on the arguments pass them to the correct variant of sendmail
error_message = []; %Set to a character array if there was an error
if exist('recipients','var') && exist('subject','var')
    if exist('message','var')
        if exist('attachments','var')
            sendmail(recipients, subject, message, attachments);
        else
            sendmail(recipients, subject, message);
        end
    else
        sendmail(recipients, subject);
    end
else
    error_message = 'Missing recipients or subject argument';
end

%Restore java properties
for i = 1:3
    if oldprops_existed(i)
        props.setProperty(propfield{i}, oldprops_values{i});
    else
        props.remove(propfield{i});
    end
end

%Restore preferences
for i = 1:4
    if exist('oldprefs','var') && isfield(oldprefs, preffield{i})
        setpref('Internet', preffield{i}, oldprefs.(preffield{i}));
    else
        rmpref('Internet', preffield{i});
    end
end
    
if ischar(error_message)
    error(error_message);
end

end

