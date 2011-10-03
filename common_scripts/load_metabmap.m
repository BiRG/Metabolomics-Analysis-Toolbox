function [ metabmap ] = load_metabmap(full_filename)
% Loads the file as a metabmap
%
%   Returns a metabmap (which is just an array of CompoundBin objects)
%   loaded from a file passed as an argument.  If the the given file is
%   invalid, an empty array is returned.

%Open the file
fid = fopen(full_filename,'r','n','ISO-8859-1');
if fid == -1
    metabmap = {};
    return;
end

%Check header to ensure file format is correct
expected_header={{'ID'},{'Metabolite'},{'Bin (Lt)'},{'Bin (Rt)'},{'Multiplicity'},{'Deconvolution'},{'Proton ID'},{'ID Source'}};
header = textscan(fid, '%q %q %q %q %q %q %q %q',1,'Delimiter',',');
if ~isequal(header,expected_header)
    msgbox('The metab-map header did not match the expected metab map header.','Error','error');
    metabmap = {};
    return;
end

%Read rows from file
rows = textscan(fid,'%f %q %f %f %q %q %q %q','Delimiter',',');

%Convert rows to bins
numbins = length(rows{1});
metabmap(numbins)=CompoundBin;
for idx=1:numbins
    metabmap(idx)=CompoundBin([...
        rows{1}(idx), rows{2}(idx), rows{3}(idx), rows{4}(idx), ...
        rows{5}(idx), rows{6}(idx), rows{7}(idx), rows{8}(idx), ...
        ]);
end

end

