function show_molecule(h_main,h_view_molecule,molecule)
main_handles = guidata(h_main);
handles = guidata(h_view_molecule);

if exist('molecule') == 1 % Variable
    setappdata(handles.figure1,'molecule',molecule); % Save the last molecule
else
    molecule = getappdata(handles.spectra,'molecule');
end

spectrum = main_handles.spectra{main_handles.spectraSelection};
x = spectrum.x;
y = spectrum.y;
height = molecule.best_height;

set(handles.molecule_name_text,'String',molecule.moleculeName);

default_width = str2double(get(handles.default_width_edit,'String'));
height_cutoff = str2double(get(handles.cutoff_height_edit,'String'));
page_number = str2num(get(handles.page_number_text,'String'));

MGPX = [];
for p = 1:length(molecule.ppm)
    MGPX = [MGPX,molecule.peakHeight(p),default_width,0,molecule.ppm(p)];
end
y_peaks = global_model(MGPX,x,length(MGPX)/4,[]);

% Break the peaks into groups
groups = [];
looking_to_start = true;
for i = 1:length(x)
    if looking_to_start
        if y_peaks(i) > height_cutoff
            groups(end+1,1) = i;
            looking_to_start = false;
        end
    else
        if y_peaks(i) < height_cutoff
            groups(end,2) = i;
            looking_to_start = true;
        end
    end
end
y_peaks = y_peaks*height;

[num_groups,cols] = size(groups);
group_axes = [handles.group1_axes,handles.group2_axes,handles.group3_axes,handles.group4_axes,handles.group5_axes,handles.group6_axes];

y_peaks = 0*x;
for g = 1:num_groups
    peak_inxs = find(x(groups(g,1)) >= molecule.ppm & molecule.ppm >= x(groups(g,2)));
    shift = molecule.best_shifts(g);
    % Create y_peaks for this multiplet
    MGPX = [];
    for i = 1:length(peak_inxs)
        p = peak_inxs(i);
        MGPX = [MGPX,molecule.peakHeight(p),default_width,0,molecule.ppm(p)+shift];
    end
    y_peaks = y_peaks + molecule.best_height*global_model(MGPX,x,length(MGPX)/4,[]);
end

num_graphs_per_page = 6;
page = 1;
hs = getappdata(handles.figure1,'hs');
delete(hs);
hs = [];
graph_inx = 1;
for g = 1:num_groups
    if page == page_number
        inxs = groups(g,1):groups(g,2);
        axes(group_axes(mod(g-1,num_graphs_per_page)+1));
        hs(end+1) = line(x(inxs),y(inxs),'Color','k');
        hs(end+1) = line(x(inxs),y_peaks(inxs),'Color','b');
%         yl = [0,max(y_peaks)];
        set(gca,'xdir','reverse');
%         ylim(yl);
        graph_inx = graph_inx + 1;
    end
    if mod(g,num_graphs_per_page) == 0
        page = page + 1;
    end
end
set(handles.total_num_pages_text,'String',num2str(page));

% Save the original set of values for the axes
if isempty(getappdata(handles.figure1,'xlim_axes1'))
    setappdata(handles.figure1,'xlim_axes1',get(handles.group1_axes,'xlim'));
    setappdata(handles.figure1,'xlim_axes2',get(handles.group2_axes,'xlim'));
    setappdata(handles.figure1,'xlim_axes3',get(handles.group3_axes,'xlim'));
    setappdata(handles.figure1,'xlim_axes4',get(handles.group4_axes,'xlim'));
    setappdata(handles.figure1,'xlim_axes5',get(handles.group5_axes,'xlim'));
    setappdata(handles.figure1,'xlim_axes6',get(handles.group6_axes,'xlim'));
    setappdata(handles.figure1,'ylim_axes1',get(handles.group1_axes,'ylim'));
    setappdata(handles.figure1,'ylim_axes2',get(handles.group2_axes,'ylim'));
    setappdata(handles.figure1,'ylim_axes3',get(handles.group3_axes,'ylim'));
    setappdata(handles.figure1,'ylim_axes4',get(handles.group4_axes,'ylim'));
    setappdata(handles.figure1,'ylim_axes5',get(handles.group5_axes,'ylim'));
    setappdata(handles.figure1,'ylim_axes6',get(handles.group6_axes,'ylim'));
end

setappdata(handles.figure1,'hs',hs);