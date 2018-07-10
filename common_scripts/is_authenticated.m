function authenticated = is_authenticated()
try
    omics_weboptions = evalin('base', 'omics_weboptions');
    res = webread('https://birg.cs.wright.edu/omics/api/currentuser', omics_weboptions);
    if isfield(res, 'name')
        authenticated = 1;
        return;
    else
        authenticated = 0;
        return;
    end
catch
    authenticated = 0;
    return;
end
end