function [ filename ] = save_binmap( filename, bin_map )
%Saves an array of compound bins to a file readable by load_binmap
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% filename  The name of the file to write to - a string
% 
% bin_map   An array of CompoundBin objects that will be written to the
%           file
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
% fn = save_binmap( filename, bin_map )
%
% Writes the compound bins in bin_map to the file filename and returns that
% name.

fid = fopen(filename,'w');
if fid == -1
    error('birg:not_open_file',['Could not open bin map file named ' ...
        filename]);
end

fprintf(fid, '%s\n', CompoundBin. csv_file_header_string);
for i = 1:length(bin_map);
    fprintf(fid, '%s\n', bin_map(i).as_csv_string);
end
fclose(fid);

end

