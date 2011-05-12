function fields = split(header_string,dlm)
fields = {};
tab = sprintf('\t');
[T,R] = strtok(header_string,dlm);
fields{end+1} = T;
while ~isempty(R)
    [T,R] = strtok(R,dlm);
    fields{end+1} = T;
    if strcmp(R,tab) % If the remainder is exactly a tab
        fields{end+1} = '';
    end
end
