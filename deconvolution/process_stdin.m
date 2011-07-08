function data = process_stdin(stdin)
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
  [key,eval_str] = strread(lines{i},'%s%s','delimiter','\t');
  key = key{1};
  %[s,iter,r,num_regions] = strread(key,'%d%d%d%d','delimiter',',');
  eval([key,';']);
  eval_str = eval_str{1};
  found = false;
  for inx = 1:length(data)
    if strcmp(data{inx}.key,key)
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
    data{inx+1}.s = s;
    data{inx+1}.r = r;
    data{inx+1}.iter = iter;
    data{inx+1}.num_regions = num_regions;
    data{inx+1}.eval_strs = {};
    data{inx+1}.eval_strs{1} = eval_str;
  else
    data{inx}.eval_strs{end+1} = eval_str;
  end
end
