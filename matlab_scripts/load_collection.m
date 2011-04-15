function collection = load_collection(filename,pathname)
ifid = fopen([pathname,filename]);
if strcmp(ifid,'"stdin"') == 1 || ifid < 0
    msgbox(['Cannot open file ',pathname,filename]);
    return
end

collection = {};
collection.filename = filename;
collection.input_names = {};

line = fgetl(ifid);
data_start = false;
while line ~= -1
    tab = sprintf('\t');
    fields = split(line,tab);
    if strcmp(fields{1},'X') == 1 || strcmp(fields{1},'x') == 1
        data_start = true;
        collection.x = [];
        collection.Y = zeros(0,length(fields)-1);
        collection.num_samples = length(fields)-1;
        str = repmat('%f',1,collection.num_samples+1);
        data = cell2mat(textscan(ifid,str,'delimiter',sprintf('\t')));
        collection.Y = data(:,2:end);
        collection.x = data(:,1);
    elseif data_start
%         collection.x(end+1) = str2num(fields{1});
%         collection.Y(end+1,1:(length(fields)-1)) = 0;
%         for j = 2:length(fields)
%             collection.Y(end,j-1) = str2num(fields{j});
%         end
    else
        input_name = fields{1};
        collection.input_names{end+1} = input_name;
        name = regexprep(input_name,' ','_');
        field_name = lower(name);
        % Try to convert to num
        values = [];
        try
            for i = 2:length(fields)
                v = str2num(fields{i});
                if ~isempty(v)
                    values(end+1) = v;
                elseif ~isempty(values)
                    values(end+1) = NaN;
                end
            end
        catch ME
            values = [];
        end
        if ~isempty(values)
            collection.(field_name) = values;
        else
            if length(fields) == 2
                collection.(field_name) = fields{2};
            else
                collection.(field_name) = {fields{2:end}};
            end
        end
    end
    line = fgetl(ifid);
end
collection.x = collection.x';
fclose(ifid);