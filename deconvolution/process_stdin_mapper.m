function data = process_stdin_mapper(stdin)
lines = strread(stdin,'%s','delimiter','\n');
% Process stdin from mapper
tmp = regexp(stdin,'Warning');
new_lines = cell(length(lines)-length(tmp),1);
% Remove warnings
cnt = 1;
for i = 1:length(lines)
  if isempty(regexp(lines{i},'^Warning.*No display specified'))
    new_lines{cnt} = lines{i};
    cnt = cnt + 1;
  end
end
lines = new_lines;

data = {};
for i = 1:length(lines)
  [key,BETA] = strread(lines{i},'%f%s','delimiter','\t');
  eval(['BETA = ',BETA{1},';']);
  found = false;
  for inx = 1:length(data)
    if data{inx}.key == key
      found = true;
      break;
    end
  end
  if isempty(inx)
    inx = 0;
  end
  if ~found
    data{inx+1} = {};
    data{inx+1}.key = key;
    data{inx+1}.BETAs = {};
    data{inx+1}.BETAs{1} = BETA;
  else
    data{inx}.BETAs{end+1} = BETA;
  end
end
