function write_test_collection_to_foo_files()
% Write a test collection with one peak to foo.* then starts targeted deconv
[collection, bin_map, deconvolved, ~, ~] = ...
    compute_test_collection(1,0.3); 

save_collection('foo.xy.txt', collection);
save_binmap('foo.bins.csv',bin_map);
save_collection('foo.dec.correct.xy.txt', deconvolved);
targeted_deconv_start;
