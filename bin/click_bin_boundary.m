function click_bin_boundary(bix,h,handles)
[bins,deconvolve] = get_bins(handles);

ButtonName = questdlg('Include in deconvolution?', ...
                         'Deconvolution', ...
                         'Yes', 'No','No');

if strcmp(ButtonName,'Yes')
    deconvolve(bix) = true;
elseif strcmp(ButtonName,'No')
    deconvolve(bix) = false;
else
    return;
end

data = cell(size(bins,1)+1,1);
data{1} = '';
for b = 1:size(bins,1)
    if deconvolve(b)
        data{b+1} = sprintf('%f,%f,Deconvolve',bins(b,1),bins(b,2));
    else
        data{b+1} = sprintf('%f,%f',bins(b,1),bins(b,2));
    end
end

set(handles.bins_listbox,'String',data);

plot_maxs(handles,true);
