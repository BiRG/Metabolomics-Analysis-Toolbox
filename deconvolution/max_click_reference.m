function max_click_reference(max_inx,h,handles)
reference = getappdata(gcf,'reference');
ButtonName = questdlg('Action?', ...
                      'Reference peak', ...
                      'Toggle mark', 'Remove peak','Toggle all','Toggle mark');

collection = getappdata(gcf,'collection');

switch ButtonName,
 case 'Toggle mark',
     [reference,collection] = toggle_mark(max_inx,reference,collection);
     [reference,collection] = renumber_matches(reference,collection);
 case 'Toggle all',
     for max_inx = 1:length(reference.maxs)
         [reference,collection] = toggle_mark(max_inx,reference,collection);
     end
     [reference,collection] = renumber_matches(reference,collection);
  case 'Remove peak',
     if reference.include_mask(max_inx) % Was previous included, toggle it off
         [reference,collection] = toggle_mark(max_inx,reference,collection);
     end
     reference.include_mask = [reference.include_mask(1:max_inx-1),reference.include_mask((max_inx+1):end)];
     max_id = reference.max_ids(max_inx);
     for s = 1:length(collection.match_ids)
         inxs_to_change = find(collection.match_ids{s} == max_id);
         collection.match_ids{s}(inxs_to_change) = 0; % Match is no longer available
     end     
     reference.max_ids = [reference.max_ids(1:max_inx-1),reference.max_ids((max_inx+1):end)];
     reference.maxs = [reference.maxs(1:max_inx-1),reference.maxs((max_inx+1):end)];
     reference.mins = [reference.mins(1:max_inx-1,:);reference.mins((max_inx+1):end,:)];
     [reference,collection] = renumber_matches(reference,collection);
end % switch

setappdata(gcf,'collection',collection);
refresh_axes2(handles);

setappdata(gcf,'reference',reference);
refresh_reference_peaks_listbox(handles);
refresh_axes1(handles);

function [reference,collection] = toggle_mark(max_inx,reference,collection)
reference.include_mask(max_inx) = ~reference.include_mask(max_inx);
max_id = reference.max_ids(max_inx); % Store old
reference.max_ids(max_inx) = 0;
if ~reference.include_mask(max_inx) % If turning it off
    if ~isfield(collection,'match_ids')
        return;
    end
    for s = 1:length(collection.match_ids)
        inxs_to_change = find(collection.match_ids{s} == max_id);
        collection.match_ids{s}(inxs_to_change) = 0; % Match is no longer available
    end
else % Turning it on
    if ~isfield(collection,'match_ids')
        return;
    end
end
