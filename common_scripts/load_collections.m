function collections = load_collections
[filenames, pathname] = uigetfile( ...
       {'*.h5', 'Omics Dashboard Collection (HDF5) files (*.h5)'; ...
        '*.zip', 'Zip files (*.zip)'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Select one or more files','MultiSelect', 'on');
if isequal(filenames,0) || isequal(pathname,0)
    collections = {};
    return;
end
if ischar(filenames)
    old_filenames = filenames;
    filenames = {};
    filenames{end+1} = old_filenames;
end
pathnames{length(filenames)} = [];
for i = 1:length(filenames)
    pathnames{i} = pathname;
end

collections = load_collections_noninteractive(filenames, pathnames);