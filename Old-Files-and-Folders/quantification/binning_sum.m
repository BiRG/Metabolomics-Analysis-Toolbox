function sum_saved_data = binning_sum(main_h,left,right)
collections = getappdata(main_h,'collections');

sum_saved_data = {};
for i = 1:length(collections)
    sum_saved_data{i} = {};
end

for i = 1:length(collections)
    for j = 1:collections{i}.num_samples
        inxs = find(left >= collections{i}.x & collections{i}.x >= right);
        y_bin = collections{i}.Y(inxs,j);
        if j == 1
            sum_saved_data{i}.Y_bin = {};
            sum_saved_data{i}.x = {};
            sum_saved_data{i}.bin_values = {};
            sum_saved_data{i}.bin_locations = {};
        end
        sum_saved_data{i}.Y_bin{j} = y_bin;
        sum_saved_data{i}.x{j} = collections{i}.x(inxs);
        sum_saved_data{i}.bin_values{j} = sum(y_bin);
        sum_saved_data{i}.bin_locations{j} = (left+right)/2;
    end
end