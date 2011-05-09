function collection = load_collection(filename,pathname)
%% Read the data once skipping the header information on the first pass
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
    end
    line = fgetl(ifid);
end
collection.x = collection.x';
fclose(ifid);

%% During this second pass we will read the header information
ifid = fopen([pathname,filename]);
if strcmp(ifid,'"stdin"') == 1 || ifid < 0
    msgbox(['Cannot open file ',pathname,filename]);
    return
end

line = fgetl(ifid);
while line ~= -1
    tab = sprintf('\t');
    fields = split(line,tab);
    if strcmp(fields{1},'X') == 1 || strcmp(fields{1},'x') == 1
        break; % This has already been done
    else
        input_name = fields{1};
        collection.input_names{end+1} = input_name;
        name = regexprep(input_name,' ','_');
        field_name = lower(name);
        if length(fields) == 2
            collection.(field_name) = fields{2};
        else
            % Try to convert to num
            values = NaN*ones(1,collection.num_samples);
            try
                for i = 2:length(fields)
                    v = str2num(fields{i});
                    if ~isempty(v)
                        values(i-1) = v;
    %                 elseif ~isempty(values)
    %                     values(end+1) = NaN;
                    end
                end
            catch ME
                values = [];
            end
            if ~isempty(values)
                collection.(field_name) = values;
            else
                values = cell(1,length(collection.num_samples));
                for i = 2:length(fields)
                    values{i-1} = fields{i};
                end
                collection.(field_name) = values;%{fields{2:end}};
            end
        end
    end
    line = fgetl(ifid);
end
fclose(ifid);