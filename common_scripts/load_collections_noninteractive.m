function collections = load_collections_noninteractive(filenames, pathnames)
%Pass a cell array of filenames and a cell array of pathnames and to get an
%array of collections.  Unlike load_collection, which handles only text
%files, this handles zip files as well.

h5_filenames = {};
h5_pathnames = {};
for k = 1:length(filenames)
    if strcmp(filenames{k}(end-2:end),'zip')
        mydir = tempname;
        mkdir(mydir);
        unzip([pathnames{k},filenames{k}],mydir);
        [hfilenames,hpathnames] = list(mydir,[mydir,'\*.h5']);
        h5_filenames = {h5_filenames{:},hfilenames{:}};
        h5_pathnames = {h5_pathnames{:},hpathnames{:}};
    else
        h5_filenames{end+1} = filenames{k};
        h5_pathnames{end+1} = pathnames{k};
    end
end

collections{length(h5_filenames)} = [];
for i = 1:length(h5_filenames)
    collections{i} = convert_to_old_format(load_hdf5_collection([h5_pathnames{i} h5_filenames{i}]));
end
