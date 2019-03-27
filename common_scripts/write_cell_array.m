function write_cell_array(filename, path, value)
% write_cell_array Write a cell array of strings to an HDF5 file.
% h5read will properly import the structure as a cell array.
%   Since h5read does not support non-numeric types, we have to use the
%   low-level API to write (but not to read) cell arrays.
%   Note that this will fail if the contents of the the cells in the array
%   are not char vectors.
%   H/T to Jason Kaeding: https://www.mathworks.com/matlabcentral/fileexchange/24091-hdf5-read-write-cellstr-example

%
for idx = 1:numel(value)
    if (iscell(value(idx)) && numel(value(idx)) > 1)
        disp('Not writing nested cell array');
        return
    end
end
if exist(filename, 'file')
    fid = H5F.open(filename ,'H5F_ACC_RDWR', 'H5P_DEFAULT');
else
    fid = H5F.create(filename);
end
% Set variable length string type
VLstr_type = H5T.copy('H5T_C_S1');
H5T.set_size(VLstr_type,'H5T_VARIABLE');

% Create a dataspace for cellstr
H5S_UNLIMITED = H5ML.get_constant_value('H5S_UNLIMITED');
dspace = H5S.create_simple(1,numel(value),H5S_UNLIMITED);

% Create a dataset plist for chunking
plist = H5P.create('H5P_DATASET_CREATE');
H5P.set_chunk(plist,2); % 2 strings per chunk

% Create dataset
dset = H5D.create(fid,path,VLstr_type,dspace,plist);

% Write data
value = cellfun(@num2str, value, 'UniformOutput', false);
H5D.write(dset,VLstr_type,'H5S_ALL','H5S_ALL','H5P_DEFAULT',value);

% Close file & resources
H5P.close(plist);
H5T.close(VLstr_type);
H5S.close(dspace);
H5D.close(dset);
H5F.close(fid);

end

