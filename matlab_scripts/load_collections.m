function collections = load_collections
[filenames, pathname] = uigetfile( ...
       {'*.zip', 'Zip files (*.zip)'; ...
        '*.txt', 'Tab delimited files (*.txt)'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Select one or more files','MultiSelect', 'on');
if length(filenames) == 0 && filenames == 0
    filenames = {};
    pathnames = {};
end
if length(filenames) == 0
    return
end
if ischar(filenames)
    old_filenames = filenames;
    filenames = {};
    filenames{end+1} = old_filenames;
end
pathnames = {};
for i = 1:length(filenames)
    pathnames{end+1} = pathname;
end

txt_filenames = {};
txt_pathnames = {};
for k = 1:length(filenames)
    if strcmp(filenames{k}(end-2:end),'zip');
        mydir = tempname;
        mkdir(mydir);
        unzip([pathnames{k},filenames{k}],mydir);
        [tfilenames,tpathnames] = list(mydir,[mydir,'\*.txt']);
        txt_filenames = {txt_filenames{:},tfilenames{:}};
        txt_pathnames = {txt_pathnames{:},tpathnames{:}};
    else
        txt_filenames{end+1} = filenames{k};
        txt_pathnames{end+1} = pathnames{k};
    end
end

collections = {};
for i = 1:length(txt_filenames)
    collections{i} = load_collection(txt_filenames{i},txt_pathnames{i})
end
