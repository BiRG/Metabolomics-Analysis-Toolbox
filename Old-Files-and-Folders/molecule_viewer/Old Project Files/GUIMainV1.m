function varargout = GUIMainV1(varargin)
% TEST M-file for GUIMainV1.fig
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

% Last Modified by GUIDE v2.5 10-Nov-2009 14:05:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_OpeningFcn, ...
                   'gui_OutputFcn',  @test_OutputFcn, ...
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
function test_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test (see VARARGIN)

% Choose default command line output for test
handles.output = hObject;

set(hObject,'toolbar','figure');

readInFiles;
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
function varargout = test_OutputFcn(hObject, eventdata, handles) 
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

set(handles.peaks_table,'ColumnName',{'ppm','Height'});
data = cell(length(handles.molecules(row).ppm),2);
for m = 1:length(handles.molecules(row).ppm)
    data{m,1} = handles.molecules(row).ppm(m);
    data{m,2} = handles.molecules(row).peakHeight(m);    
end
set(handles.peaks_table,'data',data);

handles.current_molecule_index = row;

x = getappdata(handles.output,'x');
y = getappdata(handles.output,'y');
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
max_height = y(inx);
MGPX(1:4:end) = max_height*MGPX(1:4:end);
y_peaks = global_model(MGPX,x,length(molecules(row).ppm),[]);
main_h = getappdata(handles.output,'main_h');
figure(main_h);
if isfield(handles,'h_molecule')
    delete(handles.h_molecule);
end
h_molecule = line(x,y_peaks);
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
set(getappdata(handles.output,'main_ax'),'xlim',[ppm-0.01,ppm+0.01]);


% --- Executes on slider movement.
function widthSlider_Callback(hObject, eventdata, handles)
% hObject    handle to widthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function widthSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to widthSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function heightSlider_Callback(hObject, eventdata, handles)
% hObject    handle to heightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%obtains the slider value from the slider component
%sliderValue = get(handles.heightSlider,'Value');
%disp(num2str(sliderValue);

% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function heightSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
