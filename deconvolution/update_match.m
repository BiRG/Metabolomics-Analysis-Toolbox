function update_match(handles)
reference = getappdata(gcf,'reference');
if ~isfield(reference,'max_ids') || ~isfield(reference,'include_mask')
    return;
end
reference_hlabels = findobj('Tag','axes1_hlabels');
% Make sure the order is correct
positions = get(reference_hlabels,'position');
xvs = [];
for i = 1:length(positions)
    xvs(i) = positions{i}(1);
end
[xvs,inxs] = sort(xvs,'descend');
reference_hlabels = reference_hlabels(inxs);
max_ids = reference.max_ids;
inxs1 = find(reference.include_mask == 1);
for i = 1:length(reference_hlabels)
    max_ids(inxs1(i)) = str2num(get(reference_hlabels(i),'String'));
end
reference.max_ids = max_ids;
setappdata(gcf,'reference',reference);

hlabels = findobj('Tag','axes2_hlabels');
positions = get(hlabels,'position');
xvs = [];
for i = 1:length(positions)
    xvs(i) = positions{i}(1);
end
[xvs,inxs] = sort(xvs,'descend');
hlabels = hlabels(inxs);
collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
if ~isfield(collection,'match_ids') || isempty(collection.match_ids{s}) % Nothing to check yet
    return;
end
match_ids = collection.match_ids{s};
t_error = false;
inxs2 = find(collection.include_mask{s} == 1);
new_match_ids = [];
for i = 1:length(hlabels)
    try
        v = str2num(get(hlabels(i),'String'));
        
        if v == 0 % No match for this one
            continue;
        end
        
        % Must be integer
        if v ~= round(v)
            t_error = true;
            set(hlabels(i),'color','r');
            continue;
        end
        
%         % Now check for duplicates
%         if ~isempty(find(new_match_ids == v))
%             error = true;
%             set(hlabels(i),'color','r');
%             inxs = find(match_ids == v);
%             set(hlabels(inxs),'color','r');
%             continue;
%         end
        
%         % Check to make sure it is within bounds of reference peaks
%         reference_match_ids = 1:length(inxs1);
%         if isempty(find(v == reference_match_ids))
%             t_error = true;
%             set(hlabels(i),'color','r');
%             continue;
%         end

        % Make sure it has a match
        if isempty(find(v == max_ids))
            t_error = true;
            set(hlabels(i),'color','r');
            continue;
        end
        
        new_match_ids(end+1) = v;
        set(hlabels(i),'color','k');
        match_ids(inxs2(i)) = v;
    catch ME
        t_error = true;
        set(hlabels(i),'color','r');
    end
end
if ~t_error
    collection.match_ids{s} = match_ids;
    setappdata(gcf,'collection',collection);  
end
