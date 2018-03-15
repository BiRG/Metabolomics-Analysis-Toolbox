function file = save_collection(fname_or_output_dir,suffix_or_collection, collection_if_suffix)
% Saves the collection to either a specified filename or a generated one
%
% 
% -------------------------------------------------------------------------
% Syntax:
% -------------------------------------------------------------------------
% save_collection(filename, collection)
%
% save_collection(output_dir, suffix, collection)
%
% -------------------------------------------------------------------------
% Input arguments:
% -------------------------------------------------------------------------
%
% filename    The filename to which to save the colleciton
%             A string.
%
% collection  The collection to save.  A structure.
%
% output_dir  The directory to save to (if generating the filename).  A
%             string
%
% suffix      The part of the generated filename after collection_####.  A
%             string
%
% -------------------------------------------------------------------------
% Output arguments:
% -------------------------------------------------------------------------
%
% file   The filename to which the collection was written - a string
%
% -------------------------------------------------------------------------
% Description
% -------------------------------------------------------------------------
%
% The collection will be written as a text file, overwriting any file with
% the same name.
%
% save_collection(filename, collection)  The collection will be written to
% the given filename
% 
% save_collection(output_dir, suffix, collection) The collection will be
% written to a filename of the form collection_xxxyyy.txt  in the
% directory output_dir.  xxx will be replaced with the collection_id field.
% yyy will be replaced with the contents of suffix.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% save_collection('/foo/bar/my_file.txt', col);
%
%   Will save col to "/foo/bar/my_file.txt".
%
% save_collection('/foo/bar','_test', col);
%
%   Will save col to "/foo/bar/collection_1_test.txt" if col.collection_id
%   is 1.

% UPDATE:
% Daniel Foose
% Feb/Mar 2018
% This is a wrapper for save_hdf5_collection to make it fit the old api.
% the master branch contains the old version of this function

if nargin == 3
    collection = collection_if_suffix;
    file = [fullfile(fname_or_output_dir,'collection_'), ...
        num2str(collection.collection_id),suffix_or_collection,'.h5'];
else
    collection = suffix_or_collection;
    file = fname_or_output_dir;
end

save_hdf5_collection(collection, file);