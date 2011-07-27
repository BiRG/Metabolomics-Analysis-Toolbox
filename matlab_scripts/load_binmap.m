function [ binmap ] = load_binmap(full_filename)
%INTERACTIVE_LOAD_BINMAP Loads the file as a binmap
%   Returns a binmap (which is just an array of CompoundBin objects)
%   loaded from a file passed as an argument.  If the the given file is
%   invalid, an empty array is returned.

%Open the file
fid = fopen(full_filename,'r','n','ISO-8859-1');
if fid == -1
    binmap = {};
    return;
end

%Check header to ensure file format is correct
expected_header={{'ID'},{'Metabolite'},{'Bin (Lt)'},{'Bin (Rt)'},{'multiplicity'},{'Deconvolution'},{'Proton ID'},{'ID Source'}};
header = textscan(fid, '%q %q %q %q %q %q %q %q',1,'Delimiter',',');
if ~isequal(header,expected_header)
    msgbox('The bin-map header did not match the expected bin map header.','Error','error');
    binmap = {};
    return;
end

%Read rows from file
rows = textscan(fid,'%f %q %f %f %q %q %q %q','Delimiter',',');

%Convert rows to bins
numbins = length(rows{1});
binmap(numbins)=CompoundBin;
for idx=1:numbins
    binmap(idx)=CompoundBin([...
        rows{1}(idx), rows{2}(idx), rows{3}(idx), rows{4}(idx), ...
        rows{5}(idx), rows{6}(idx), rows{7}(idx), rows{8}(idx), ...
        ]);
end

end

