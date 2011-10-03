function [ filename ] = save_metabmap( filename, metab_map )
%Saves an array of compound bins to a file readable by load_metabmap
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% filename   The name of the file to write to - a string
% 
% metab_map  An array of CompoundBin objects that will be written to the
%            file
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% filename  The file that was written to
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% fn = save_metabmap( filename, metab_map )
%
% Writes the compound bins in metab_map to the file filename and
% returns that name.

fid = fopen(filename,'w');
if fid == -1
    error('birg:not_open_file',['Could not open metab map file named ' ...
        filename]);
end

fprintf(fid, '%s\n', CompoundBin. csv_file_header_string);
for i = 1:length(metab_map);
    fprintf(fid, '%s\n', metab_map(i).as_csv_string);
end
fclose(fid);

end

