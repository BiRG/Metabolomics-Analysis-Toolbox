function [bins,deconvolve] = get_bins(handles)
bins = [];
deconvolve = [];
data = get(handles.bins_listbox,'String');
for b = 2:size(data,1) % Skip the first blank
    fields = split(data{b},',');    
    bins(end+1,:) = [str2num(fields{1}),str2num(fields{2})];
    if length(fields) == 2
        deconvolve(end+1) = false;
    elseif strcmp(fields{3},'Deconvolve')
        deconvolve(end+1) = true;
    end
end
