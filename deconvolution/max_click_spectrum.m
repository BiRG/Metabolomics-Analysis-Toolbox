function max_click_spectrum(max_inx,h,handles)
collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
ButtonName = questdlg('Action?', ...
                      'Spectrum peak', ...
                      'Toggle mark', 'Remove peak','Toggle all','Toggle mark');
switch ButtonName,
 case 'Toggle all',
     collection.include_mask{s} = ~collection.include_mask{s};
     if isfield(collection,'match_ids') && ~isempty(collection.match_ids{s})
        collection.match_ids{s} = 0;
     end
     setappdata(gcf,'collection',collection);
     
     refresh_axes2(handles);
 case 'Toggle mark',
     collection.include_mask{s}(max_inx) = ~collection.include_mask{s}(max_inx);
     if isfield(collection,'match_ids') && ~isempty(collection.match_ids{s})
        collection.match_ids{s}(max_inx) = 0;
     end
     setappdata(gcf,'collection',collection);
     
     refresh_axes2(handles);
 case 'Remove peak',
     collection.include_mask{s} = [collection.include_mask{s}(1:max_inx-1),collection.include_mask{s}((max_inx+1):end)];
     collection.BETA{s} = [collection.BETA{s}(1:(4*(max_inx-2)+4));collection.BETA{s}((4*(max_inx)+1):end)];
     if isfield(collection,'match_ids') && ~isempty(collection.match_ids{s})
        collection.match_ids{s} = [collection.match_ids{s}(1:max_inx-1),collection.match_ids{s}((max_inx+1):end)];     
     end
     collection.maxs{s} = [collection.maxs{s}(1:max_inx-1),collection.maxs{s}((max_inx+1):end)];
     collection.mins{s} = [collection.mins{s}(1:max_inx-1,:);collection.mins{s}((max_inx+1):end,:)];
     collection.dirty(s) = true;
%      delete(h);
%      hmaxs = getappdata(gcf,'axes2_hmaxs');
%      hmaxs = [hmaxs(1:max_inx-1),hmaxs((max_inx+1):end)];
%      setappdata(gcf,'axes2_hmaxs',hmaxs);
     setappdata(gcf,'collection',collection);
     
     refresh_axes2(handles);
end % switch

