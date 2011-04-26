function collection = bin_collection(main_h,collections,c,left_handles)
collection = collections{c};
num_regions = length(left_handles);
collection.Y = zeros(num_regions,collection.num_samples);
% collection = rmfield(collection,'spectra');
collection.x = [];
bix = 1;
for i = 1:num_regions
    show_bin(main_h,i,true);
    info = getappdata(left_handles(i),'info');
    if strcmp(info.binning_method,'sum')
        sum_saved_data = getappdata(left_handles(i),'sum_saved_data');
        for j = 1:collection.num_samples
            collection.x(bix,1) = sum_saved_data{c}.bin_locations{j};
            collection.Y(bix,j) = sum_saved_data{c}.bin_values{j};
        end
    elseif strcmp(info.binning_method,'smart')
        smart_saved_data = getappdata(left_handles(i),'smart_saved_data');
        for j = 1:collection.num_samples
            collection.x(bix,1) = smart_saved_data{c}.bin_locations{j};
            collection.Y(bix,j) = smart_saved_data{c}.bin_values{j};
        end
    elseif strcmp(info.binning_method,'adj')
        adj_saved_data = getappdata(left_handles(i),'adj_saved_data');
        for j = 1:collection.num_samples
            for m = 1:length(adj_saved_data{c}.bin_locations{j})
                if j == 1
                    collection.x(bix+m-1,1) = adj_saved_data{c}.bin_locations{j}(m);
                    collection.Y(bix+m-1,j) = adj_saved_data{c}.bin_values{j}(m);
                else
                    collection.Y(bix+m-1,j) = adj_saved_data{c}.bin_values{j}(m);
                end
            end
        end
        if ~isempty(m)
            bix = bix + m - 1;
        else
            bix = bix - 1;
        end
    end
    bix = bix + 1;
end
collection.processing_log = [collection.processing_log,' Binned.'];