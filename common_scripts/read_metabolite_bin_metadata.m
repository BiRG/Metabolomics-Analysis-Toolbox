% FUNCTION READ_METABOLITE_BIN_METADATA
function [regions, deconvolve, names] = read_metabolite_bin_metadata()
% No params
[filename, pathname] = uigetfile({'*.csv','Row-dominant comma-delimited (*.csv)';'*.txt','Old column-dominant (*.txt)'}, 'Load regions');
if (isnumeric(filename) && filename == 0)
    regions = -1;
    deconvolve = -1;
    names = -1;
    return;
end

% TODO: Take this file opening block out & put it into its own lib.
[file_id, message] = fopen([pathname filename],'r');
if (file_id <= 2)
    msgbox(message);
    regions = -2;
    deconvolve = -2;
    names = -2;
    return;
end

binFileData = textscan(file_id,'%f,%f,%s','Delimiter','\n');
fclose(file_id);

% Check for old file format.
if (isempty(binFileData{3}))
    % It's the old format. Reread file and fit it to the structure.
    
    % TODO: Take this file opening block out & put it into its own lib.
    [file_id, message] = fopen([pathname filename],'r');
    % Error-check again, just to be paranoid.
    if (file_id <= 2)
        msgbox(message);
        regions = -3;
        deconvolve = -3;
        names = -3;
        return;
    end
    
    % Pull the comma'd pairs, delimited by semicolons.
    binFileData = textscan(file_id,'%f,%f','Delimiter',';\n');
    
    % Pull the operation strings ("sum" vs. "deconvolve") and name
    % strings associated with each bin, delimited by semicolons. We
    % bastardize the stringFields variable here as it will all need to end
    % up there anyways.
    stringFields = textscan(file_id,'%s','EndOfLine','\n');
    fclose(file_id);
    
    % Have to dereference the wrapping 1x1 cell before splitting.
    tempStringFields = split(stringFields{1},';');
    stringFields = cell(length(tempStringFields{1}),1);
    
    if (length(tempStringFields) == 1)
        % There were no names. Append a cell array of blanks.
        tempStringFields = {tempStringFields{1} ; cell(1, length(tempStringFields{1}))};
    end
    
    % Merge stringFields & nameFields into the nx1 cell array structure
    % with each element referencing a 1x2 cell of strings.
    for index = 1:length(stringFields)
        stringFields{index} = { tempStringFields{1}{index} tempStringFields{2}{index} };
    end
    
else
    % It's the current format!
    
    % Parse out the operation strings ("sum" vs. "deconvolve")
    % from the name strings.
    stringFields = regexp(binFileData{3},'"(.*)","(.*)"$','tokens');
    
    % Flatten the structure
    stringFields = stringFields(:);
    stringFields = [ stringFields{:} ]';
end

regions = [ binFileData{1} binFileData{2} ];
binCount = length(stringFields);

% Due to the cell array structure, have to iterate through
deconvolve = false(binCount,1);
for i = 1:binCount
    deconvolve(i) = strcmp(stringFields{i}(1),'deconvolve');
end

names = cell(binCount,1);
for i = 1:binCount
    names(i) = stringFields{i}(2);
end
