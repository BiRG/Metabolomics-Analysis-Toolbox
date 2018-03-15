function authenticated = is_authenticated()
try
    evalin('base', 'omics_weboptions');
catch ME
    authenticated = 0;
    return;
end
omics_weboptions = evalin('base', 'omics_weboptions');
res = webread('https://birg.cs.wright.edu/omics/api/currentuser', omics_weboptions);
if isfield(res, 'name')
    authenticated = 1;
    return;
end
authenticated = 0;
end