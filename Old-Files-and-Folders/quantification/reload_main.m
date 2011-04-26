[filename, pathname] = uigetfile( ...
       {'*.fig', 'MATLAB figure (*.fig))'}, ...
        'Reload a MATLAB figure');
if length(filename) == 0
    return
end

open([pathname,filename]);

% Gives the conversion
handles = findobj;
saved_handles = zeros(size(handles));
for i = 1:length(saved_handles)
    if isappdata(handles(i),'saved_handle')
        saved_handles(i) = getappdata(handles(i),'saved_handle');
    end
end

% yhs
yhs = getappdata(gcf,'yhs');
for i = 1:length(yhs)
    inx = find(saved_handles == yhs(i),1);
    yhs(i) = handles(inx); % Update the handles
end
setappdata(gcf,'yhs',yhs);

% lh
lh = getappdata(gcf,'lh');
inx = find(saved_handles == lh,1);
lh = handles(inx); % Update the handles
setappdata(gcf,'lh',lh);

% fhs
setappdata(gcf,'fhs',[]);

% VerticalCursors
VerticalCursors = getappdata(gcf,'VerticalCursors');
for i = 1:length(VerticalCursors)
    inx = find(saved_handles == VerticalCursors{i}.Handles(1),1);
    VerticalCursors{i}.Handles(1) = handles(inx);
    inx = find(saved_handles == VerticalCursors{i}.Handles(2),1);
    VerticalCursors{i}.Handles(2) = handles(inx);    
end
setappdata(gcf,'VerticalCursors',VerticalCursors);

% Regions cursors
regions_cursors = getappdata(gcf,'regions_cursors');
nm = size(regions_cursors);
for i = 1:nm(1)
    if ~is_integer(regions_cursors(i,1))
        inx = find(saved_handles == regions_cursors(i,1),1);
        regions_cursors(i,1) = handles(inx);
    end
    if ~is_integer(regions_cursors(i,2))
        inx = find(saved_handles == regions_cursors(i,2),1);
        regions_cursors(i,2) = handles(inx);
    end    
end
setappdata(gcf,'regions_cursors',regions_cursors);