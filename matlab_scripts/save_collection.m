function file = save_collection(output_dir,suffix,collection)
file = [output_dir,'\collection_',num2str(collection.collection_id),suffix,'.txt'];
fid = fopen(file,'w');
for i = 1:length(collection.input_names)
    name = regexprep(collection.input_names{i},' ','_');
    field_name = lower(name);
    if i > 1
        fprintf(fid,'\n');
    end
    fprintf(fid,collection.input_names{i});
    if iscell(collection.(field_name))
        for j = 1:length(collection.(field_name))
            if ischar(collection.(field_name){j})
                fprintf(fid,'\t%s',collection.(field_name){j});
            elseif int8(collection.(field_name){j}) == collection.(field_name){j} % Integer
                fprintf(fid,'\t%d',collection.(field_name){j});
            else
                fprintf(fid,'\t%f',collection.(field_name){j});
            end
        end
    elseif ischar(collection.(field_name))
        fprintf(fid,'\t%s',collection.(field_name));
    elseif length(collection.(field_name)) > 1 % Array
        for j = 1:length(collection.(field_name))
            if ischar(collection.(field_name)(j))
                fprintf(fid,'\t%s',collection.(field_name)(j));
            elseif int32(collection.(field_name)(j)) == collection.(field_name)(j) % Integer
                fprintf(fid,'\t%d',collection.(field_name)(j));
            else
                fprintf(fid,'\t%f',collection.(field_name)(j));
            end
        end
    elseif int32(collection.(field_name)) == collection.(field_name) % Integer
        fprintf(fid,'\t%d',collection.(field_name));
    else
        fprintf(fid,'\t%f',collection.(field_name));
    end
end
fprintf(fid,'\nX');
for i = 1:collection.num_samples
    fprintf(fid,'\tY%d',i);
end
for j = 1:length(collection.x)
    fprintf(fid,'\n%f',collection.x(j));
    for i = 1:collection.num_samples
        fprintf(fid,'\t%f',collection.Y(j,i));
    end
end
fclose(fid);