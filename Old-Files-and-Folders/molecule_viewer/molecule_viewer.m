function varargout = molecule_viewer(varargin)
% TEST M-file for molecule_viewer.fig
%      TEST, by itself, creates a new TEST or raises the existing
%      singleton*.
%
%      H = TEST returns the handle to a new TEST or the handle to
%      the existing singleton*.
%
%      TEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST.M with the given input arguments.
%
%      TEST('Property','Value',...) creates a new TEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test

% Last Modified by GUIDE v2.5 14-Nov-2009 21:53:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @molecule_viewer_OpeningFcn, ...
                   'gui_OutputFcn',  @molecule_viewer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before test is made visible.
function molecule_viewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)

% Choose default command line output for test
handles.output = hObject;

% set(hObject,'toolbar','figure');

load('molecules','molecules');
handles.molecules = molecules;

set(handles.uitable1,'ColumnName','Molecule');
data = cell(length(handles.molecules),1);
for m = 1:length(handles.molecules)
    data{m,1} = handles.molecules(m).moleculeName;
end
set(handles.uitable1,'data',data);

%axes(handles.plotGraph)
%title('Plot Graph!');
%xlabel('Chemical shift, ppm');
%ylabel('Peak Height');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = molecule_viewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in chageDataButton.
function chageDataButton_Callback(hObject, eventdata, handles)
% hObject    handle to chageDataButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

molecules = handles.molecules;
row = eventdata.Indices(1,1);

try
set(handles.peaks_table,'ColumnName',{'ppm','Height'});
data = cell(length(handles.molecules(row).ppm),2);
for m = 1:length(handles.molecules(row).ppm)
    data{m,1} = handles.molecules(row).ppm(m);
    data{m,2} = handles.molecules(row).peakHeight(m);    
end
set(handles.peaks_table,'data',data);
catch ME
    disp('here');
end

handles.current_molecule_index = row;

x = getappdata(handles.output,'x');
y = getappdata(handles.output,'y');
main_ax = getappdata(handles.output,'main_ax');
yl = get(main_ax,'ylim');

if ~isfield(handles.molecules(row),'MGPX') || length(handles.molecules(row).MGPX)/4 ~= length(molecules(row).ppm)
    MGPX = [];
    loc_of_height = 0;
    min_height = Inf;
    for p = 1:length(molecules(row).ppm)
        if molecules(row).peakHeight(p) < min_height
            loc_of_height = molecules(row).ppm(p);
            min_height = molecules(row).peakHeight(p);
        end
        MGPX = [MGPX,molecules(row).peakHeight(p),0.005,0,molecules(row).ppm(p)];
    end
    [mn,inx] = min(abs(x-loc_of_height));
    max_height = sum(yl)/2;
    MGPX(1:4:end) = max_height*MGPX(1:4:end);
else
    MGPX = handles.molecules(row).MGPX;
end

set(handles.peak_height_slider,'Min',0);
set(handles.peak_height_slider,'Max',max(y));
set(handles.peak_height_slider,'Value',max(MGPX(1:4:end)));

y_peaks = global_model(MGPX,x,length(molecules(row).ppm),[]);
main_h = getappdata(handles.output,'main_h');
figure(main_h);
if isfield(handles,'h_molecule')
    try
        delete(handles.h_molecule);
    catch ME
    end
end
if isfield(handles,'h_peaks')
    for i = 1:length(handles.h_peaks)
        try
            delete(handles.h_peaks(i));
        catch ME
        end
    end
    handles.h_peaks = [];
end
handles.molecules(row).MGPX = MGPX;
h_molecule = line(x,y_peaks,'Color','g');
handles.h_molecule = h_molecule;
figure(handles.output);

guidata(hObject, handles);


% --- Executes on button press in updateTableButton.
function updateTableButton_Callback(hObject, eventdata, handles)
% hObject    handle to updateTableButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

readInFiles;
handles.molecules = molecules;

set(handles.uitable1,'ColumnName','Molecule');
data = cell(length(handles.molecules),1);
for m = 1:length(handles.molecules)
    data{m,1} = handles.molecules(m).moleculeName;
end
set(handles.uitable1,'data',data);
set(handles.uitable1,'ColumnWidth','Auto');
% 
% set(handles.uitable1,'ColumnName',{'Molecule','First ppm'});
% data = cell(length(handles.molecules),2);
% for m = 1:length(handles.molecules)
%     data{m,1} = handles.molecules(m).moleculeName;
%     data{m,2} = m;
% end
% set(handles.uitable1,'data',data);
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function plotGraph_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotGraph (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate plotGraph


% --- Executes on button press in updatePlotButton.
function updatePlotButton_Callback(hObject, eventdata, handles)
% hObject    handle to updatePlotButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%selects axes1 as the current axes, so that 
%Matlab knows where to plot the data
axes(handles.plotGraph)
 
%creates a vector from 0 to 10, [0 1 2 3 . . . 10]
x = 0:10;
%creates a vector from 0 to 10, [0 1 2 3 . . . 10]
y = 0:10;
 
%plots the x and y data
plot(x,y);
%adds a title, x-axis description, and y-axis description
title('Plot Graph!');
xlabel('X data');
ylabel('Y data');
guidata(hObject, handles); %updates the handles

% --- Executes on button press in loadGraphButton.
function loadGraphButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadGraphButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%selects axes1 as the current axes, so that 
%Matlab knows where to plot the data
axes(handles.plotGraph)

%file = whateverx188isStoredAs
%load(file);
load('x188');
x = x188(:,1);
y = x188(:,2);
 
%plots the x and y data
plot(x,y);
set(gca,'xdir','reverse');

%adds a title, x-axis description, and y-axis description
title('Plot Graph!');
xlabel('Chemical shift, ppm');
ylabel('Peak Height');
guidata(hObject, handles); %updates the handles


% --- Executes on selection change in peaks_listbox.
function peaks_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to peaks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns peaks_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from peaks_listbox


% --- Executes during object creation, after setting all properties.
function peaks_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peaks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in peaks_table.
function peaks_table_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to peaks_table (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

p = eventdata.Indices(1,1);
ppm = handles.molecules(handles.current_molecule_index).ppm(p);
main_ax = getappdata(handles.output,'main_ax');
xl = get(main_ax,'xlim');
width = abs(xl(1)-xl(2));
set(main_ax,'xlim',[ppm-width/2,ppm+width/2]);
if isfield(handles,'h_peaks')
    peaks_ax = get(handles.h_peaks,'CurrentAxes');
    set(peaks_ax,'xlim',[ppm-width/2,ppm+width/2]);
end

% --- Executes on slider movement.
function peak_height_slider_Callback(hObject, eventdata, handles)
% hObject    handle to peak_height_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
max_height = get(handles.peak_height_slider,'Value');
try
    MGPX = handles.molecules(handles.current_molecule_index).MGPX;
    MGPX(1:4:end) = handles.molecules(handles.current_molecule_index).peakHeight*max_height;
    handles.molecules(handles.current_molecule_index).MGPX = MGPX;
catch ME
end
x = getappdata(handles.output,'x');
molecules = handles.molecules;
y_peaks = global_model(MGPX,x,length(molecules(handles.current_molecule_index).ppm),[]);
main_h = getappdata(handles.output,'main_h');
figure(main_h);
if isfield(handles,'h_molecule')
    try
        delete(handles.h_molecule);
    catch ME
    end
end
if isfield(handles,'h_peaks')
    for i = 1:length(handles.h_peaks)
        try
            delete(handles.h_peaks(i));
        catch ME
        end
    end
    handles.h_peaks = [];
end
h_molecule = line(x,y_peaks,'Color','g');
handles.h_molecule = h_molecule;
figure(handles.output);

guidata(hObject, handles); %updates the handles

% --- Executes during object creation, after setting all properties.
function peak_height_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_height_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function peak_width_slider_Callback(hObject, eventdata, handles)
% hObject    handle to peak_width_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(hObject,'Value'));
disp(get(hObject,'Min'));
disp(get(hObject,'Max'));

% --- Executes during object creation, after setting all properties.
function peak_width_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_width_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over peak_height_slider.
function peak_height_slider_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to peak_height_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    delete(handles.h_molecule);
catch ME
end

if isfield(handles,'h_peaks')
    for i = 1:length(handles.h_peaks)
        try
            delete(handles.h_peaks(i));
        catch ME
        end
    end
    handles.h_peaks = [];
end

% Hint: delete(hObject) closes the figure
delete(hObject);


% --- Executes on button press in update_height_slider.
function update_height_slider_Callback(hObject, eventdata, handles)
% hObject    handle to update_height_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_ax = getappdata(handles.output,'main_ax');
yl = get(main_ax,'ylim');
set(handles.peak_height_slider,'Max',max([yl(2),get(handles.peak_height_slider,'Value')]));


% --- Executes on button press in sort_proximity_button.
function sort_proximity_button_Callback(hObject, eventdata, handles)
% hObject    handle to sort_proximity_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

main_ax = getappdata(handles.output,'main_ax');
xl = get(main_ax,'xlim');
center = sum(xl)/2;
min_distances = zeros(1,length(handles.molecules));
names = {};
for i = 1:length(min_distances)
    min_dist = min(abs(handles.molecules(i).ppm - center));
    try
        min_distances(i) = min_dist;
        names{i} = handles.molecules(i).moleculeName;
    catch ME
        min_distances(i) = Inf;
        names{i} = 'No name';
    end    
end
[vs,inxs] = sort(names);
handles.molecules = handles.molecules(inxs);
try
    handles.current_molecule_index = inxs(handles.current_molecule_index);
end
data = cell(length(handles.molecules),1);
for m = 1:length(handles.molecules)
    data{m,1} = handles.molecules(m).moleculeName;
end
set(handles.uitable1,'data',data);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in adjust_to_best.
function adjust_to_best_Callback(hObject, eventdata, handles)
% hObject    handle to adjust_to_best (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isfield(handles,'h_peaks')
    for i = 1:length(handles.h_peaks)
        try
            delete(handles.h_peaks(i));
        catch ME
        end
    end
    handles.h_peaks = [];
end

molecule = handles.molecules(handles.current_molecule_index);
main_ax = getappdata(gcf,'main_ax');
xl = get(main_ax,'xlim');
% Find all peaks in the window
inxs = find(xl(1) <= molecule.ppm & molecule.ppm <= xl(2));
if isempty(inxs)
    msgbox('No molecule peaks in window');
    return
end
main_h = getappdata(gcf,'main_h');
reference = getappdata(main_h,'reference');
if isempty(reference)
    msgbox('Set reference');
    return;
end
minxs = find(xl(1) <= reference.X & reference.X <= xl(2));
if isempty(minxs)
    msgbox('No reference peaks in window');
    return
end

xwidth = abs(reference.x(1) - reference.x(2));
Y_peaks = zeros(length(inxs)*length(minxs)+1,length(reference.x));
X_peaks = zeros(length(inxs)*length(minxs)+1,length(reference.x));
X_peaks(1,:) = reference.x;
Y_peaks(1,:) = reference.y;
cnt = 2;
for i = 1:length(inxs)
    p = inxs(i);
    for j = 1:length(minxs)
        m = minxs(j);
        if m == 1
            left = reference.x(1);
        else
            left = reference.X(minxs(j) - 1) - xwidth;
        end
        if m == length(reference.X)
            right = reference.x(end);
        else
            right = reference.X(minxs(j) + 1) + xwidth;
        end
        inxs1 = find(left >= reference.x & reference.x > reference.X(m));
        inxs2 = find(reference.X(m) > reference.x & reference.x >= right);
        [v,inx1] = min(reference.y(inxs1));
        inx1 = inxs1(inx1);
        [v,inx2] = min(reference.y(inxs2));
        inx2 = inxs2(inx2);
        cinxs = inx1:inx2;
        width = calc_width(cinxs,reference.x,reference.y);
        height = calc_height(cinxs,reference.y);
        MGPX = molecule.MGPX;
        mult = height/molecule.peakHeight(p);
        MGPX(1:4:end) = molecule.peakHeight*mult;
        MGPX(2:4:end) = width;
        xdiff = reference.X(minxs(j)) - molecule.ppm(p);
        MGPX(4:4:end) = molecule.ppm + xdiff;
        y_peaks = global_model(MGPX,reference.x,length(molecule.ppm),[]);
        Y_peaks(cnt,:) = y_peaks;
        X_peaks(cnt,:) = reference.x;
        cnt = cnt + 1;
    end
end

handles.h_peaks = figure;
plot(X_peaks',Y_peaks');
xlim(xl);
legend('Reference');
set(gca,'xdir','reverse');

% Update handles structure
guidata(hObject, handles);