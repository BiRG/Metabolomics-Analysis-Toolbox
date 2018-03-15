function options = get_weboptions(email, password)
initial_options = weboptions('CertificateFilename', '', 'MediaType', 'application/json');
credentials = struct('email', email, 'password', password); 
res = webwrite('https://birg.cs.wright.edu/omics/api/authenticate', credentials, initial_options);
auth_token = ['JWT' ' ' char(res.token)];
options = weboptions('CertificateFilename', '', 'MediaType', 'application/json', 'HeaderFields', {'Authorization', auth_token});
end