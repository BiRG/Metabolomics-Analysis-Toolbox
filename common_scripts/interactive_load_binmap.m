function [ binmap ] = interactive_load_binmap()
%INTERACTIVE_LOAD_BINMAP Displays a file dialog and loads the file as a binmap
%   Returns a binmap (which is just an array of CompoundBin objects)
%   loaded from a file selected by the user.  If the user does not select a
%   file, then an empty array is returned

%Get the filename from the user
[filename,pathname] = uigetfile('*.csv','Select a bin map file');

if filename == 0
    binmap = {};
    return;
end

binmap = load_binmap(fullfile(filename, pathname));
