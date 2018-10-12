function backup_collection(collection_ids)
    for i = 1:size(collection_ids,1)
        collection_id = collection_ids(i)
        collection=get_old_collection(collection_id, 'Daniel Foose', 'APoCoPo');
        filename = ['/home/birguser/omics_backup/collections/' int2str(collection_id) '.h5']
        save_hdf5_collection(collection, filename);
    end
end