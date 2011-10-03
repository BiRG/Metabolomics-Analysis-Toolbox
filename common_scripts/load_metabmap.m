function [ metabmap ] = load_metabmap(full_filename)
% Loads the file as a metabmap
%
%   Returns a metabmap (which is just an array of CompoundBin objects)
%   loaded from a file passed as an argument.  If the the given file is
%   invalid, an empty array is returned.

%Open the file
fid = fopen(full_filename,'r','n','ISO-8859-1');
if fid == -1
    metabmap = [];
    return;
end

header = fgetl(fid);
metabmap = CompoundBin; %Array with one element to set the type to CompoundBin
metabmap(1)=[];         %Erase the element to have empty array of CompoundBin
if ischar(header)
    while true
        line = fgetl(fid);
        if ischar(line)
            try
                metabmap(end+1) = CompoundBin(header, line); %#ok<AGROW>
            catch err
                if isequal(err.identifier, 'CompoundBin:unknown_header')
                    msgbox(['The metab-map had an unrecognized header: "'...
                        header '"'],'Error','error');
                    metabmap = [];
                    return;
                else
                    msgbox(['Problem creating bin from metab-map file ' ...
                        'line.  The line was: ' line ...
                        'The error message was: ' err.message ], ...
                        'Error','error');
                    metabmap = [];
                    return;
                end
            end
        else
            break;
        end
    end
else
    msgbox('The metab-map file was empty','Error','error');
    metabmap = [];
    return;
end


end

