function converted = convert_to_new_format(collection)
    wavenumber_count = max(size(collection.('x')));
    sample_count = get_sample_count(collection.('Y'), wavenumber_count);
    keys = fieldnames(collection);
    for i = 1:size(keys,1)
        key = keys{i};
        field_size = size(collection.(key));
        % make sure that for single column
        if min(field_size) == 1 % we have a single column 'label'
            if max(field_size) == wavenumber_count % we have column labels
                if field_size(2) ~= wavenumber_count % ensure number of columns agree
                    collection.(key) = collection.(key)';
                end
            elseif max(field_size) == sample_count % we have row labels
                if field_size(1) ~= sample_count % ensure number of rows agree
                    collection.(key) = collection.(key)';
                end
            end
        elseif min(field_size) == sample_count % this is most likely y
            if field_size(1) ~= sample_count % ensure that the number of rows is sample count
                collection.(key) = collection.(key)';
            end
        end
    end
    % fix x
    x_size = size(collection.('x'));
    if x_size(2) ~= wavenumber_count
        collection.('x') = collection.('x')';
    end
    converted = collection;
end

function val = get_sample_count(Y, wavenumber_count)
    Y_size = size(Y);
    val = Y_size(Y_size ~= wavenumber_count);
end