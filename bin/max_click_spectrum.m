function max_click_spectrum(h,eventdata)
s = getappdata(h,'s');
max_inx = getappdata(h,'max_inx');
handles = guidata(h);
collection = handles.collection;
ButtonName = questdlg('Action?', ...
                      'Spectrum peak', ...
                      'Toggle mark', 'Remove peak','Toggle mark');
switch ButtonName,
 case 'Toggle mark',
     collection.include_mask{s}(max_inx) = ~collection.include_mask{s}(max_inx);
     
     if collection.include_mask{s}(max_inx)
         set(h,'color','b');
         set(h,'MarkerFaceColor','b');
     else
         set(h,'color',[0.8,0.8,0.8]);
         set(h,'MarkerFaceColor',[0.8,0.8,0.8]);
     end
     
     handles.collection = collection;
     guidata(handles.figure1, handles);
 case 'Remove peak',
     collection.include_mask{s} = [collection.include_mask{s}(1:max_inx-1),collection.include_mask{s}((max_inx+1):end)];
     collection.BETA{s} = [collection.BETA{s}(1:(4*(max_inx-2)+4));collection.BETA{s}((4*(max_inx)+1):end)];
     collection.maxs{s} = [collection.maxs{s}(1:max_inx-1),collection.maxs{s}((max_inx+1):end)];
     collection.mins{s} = [collection.mins{s}(1:max_inx-1,:);collection.mins{s}((max_inx+1):end,:)];     
     
     delete(h);
     
     handles.collection = collection;
     guidata(handles.figure1, handles);
end % switch