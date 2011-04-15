function varargout = view_molecule(varargin)
% VIEW_MOLECULE M-file for view_molecule.fig
%      VIEW_MOLECULE, by itself, creates a new VIEW_MOLECULE or raises the existing
%      singleton*.
%
%      H = VIEW_MOLECULE returns the handle to a new VIEW_MOLECULE or the handle to
%      the existing singleton*.
%
%      VIEW_MOLECULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIEW_MOLECULE.M with the given input arguments.
%
%      VIEW_MOLECULE('Property','Value',...) creates a new VIEW_MOLECULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before view_molecule_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to view_molecule_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help view_molecule

% Last Modified by GUIDE v2.5 08-Feb-2010 08:53:15

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @view_molecule_OpeningFcn, ...
                   'gui_OutputFcn',  @view_molecule_OutputFcn, ...
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


% --- Executes just before view_molecule is made visible.
function view_molecule_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to view_molecule (see VARARGIN)

% Choose default command line output for view_molecule
handles.output = hObject;

handles.page_number = 1;

%Testing, may need changed.
handles.checkInitValues = 0;
%set(handles.slider10,'Value', .5);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes view_molecule wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = view_molecule_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function default_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to default_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of default_width_edit as text
%        str2double(get(hObject,'String')) returns contents of default_width_edit as a double
show_molecule;

% --- Executes during object creation, after setting all properties.
function default_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to default_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cutoff_height_edit_Callback(hObject, eventdata, handles)
% hObject    handle to cutoff_height_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cutoff_height_edit as text
%        str2double(get(hObject,'String')) returns contents of cutoff_height_edit as a double
show_molecule;

% --- Executes during object creation, after setting all properties.
function cutoff_height_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cutoff_height_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in next_groups_pushbutton.
function next_groups_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to next_groups_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Signals for the axes to be updated in the handles if sliders are used.
handles.checkInitValues = 0;

page_number = str2num(get(handles.page_number_text,'String'));
set(handles.page_number_text,'String',page_number+1);
show_molecule;

% --- Executes on button press in previous_groups_pushbutton.
function previous_groups_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to previous_groups_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Signals for the axes to be updated in the handles if sliders are used.
handles.checkInitValues = 0;

page_number = str2num(get(handles.page_number_text,'String'));
page_number = page_number - 1;
if page_number < 1
    page_number = 1;
end
set(handles.page_number_text,'String',page_number);
show_molecule;


% --- Executes on slider movement.
function height_slider_Callback(hObject, eventdata, handles)
% hObject    handle to height_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
disp(get(handles.height_slider, 'Value'));

% --- Executes during object creation, after setting all properties.
function height_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function shift_allowance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to shift_allowance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of shift_allowance_edit as text
%        str2double(get(hObject,'String')) returns contents of shift_allowance_edit as a double


% --- Executes during object creation, after setting all properties.
function shift_allowance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift_allowance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider4_Callback(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider7_Callback(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider8_Callback(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider9_Callback(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the upper left (top) slider Y-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider9, 'Value');
yTop = handles.axe1yLims(1);
yBottom = handles.axe1yLims(2);
difference = yTop - yBottom;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
%newYTop = yBottom + frameSize;
newYBottom = yTop - frameSize;

% Updates what the new display values for y length should be!
set(handles.group1_axes, 'ylim', [yTop newYBottom]);

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function slider9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider10_Callback(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

% This is the upper left (top) slider.

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider10, 'Value');
xRight = handles.axe1xLims(1);
xLeft = handles.axe1xLims(2);
difference = xLeft - xRight;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
newXRight = xRight + frameSize;
newXLeft = xLeft - frameSize;

% Updates what the new display values for x length should be!
set(handles.group1_axes, 'xlim', [newXLeft newXRight]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider11_Callback(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

% This is the middle(top) slider X-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider11, 'Value');
xRight = handles.axe2xLims(1);
xLeft = handles.axe2xLims(2);
difference = xLeft - xRight;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
newXRight = xRight + frameSize;
newXLeft = xLeft - frameSize;

% Updates what the new display values for x length should be!
set(handles.group2_axes, 'xlim', [newXLeft newXRight]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider12_Callback(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the middle (top) slider Y-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider12, 'Value');
yTop = handles.axe2yLims(1);
yBottom = handles.axe2yLims(2);
difference = yTop - yBottom;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
%newYTop = yBottom + frameSize;
newYBottom = yTop - frameSize;

% Updates what the new display values for y length should be!
set(handles.group2_axes, 'ylim', [yTop newYBottom]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider13_Callback(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

% This is the right (top) slider X-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider13, 'Value');
xRight = handles.axe3xLims(1);
xLeft = handles.axe3xLims(2);
difference = xLeft - xRight;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
newXRight = xRight + frameSize;
newXLeft = xLeft - frameSize;

% Updates what the new display values for x length should be!
set(handles.group3_axes, 'xlim', [newXLeft newXRight]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider14_Callback(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the right (top) slider Y-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider14, 'Value');
yTop = handles.axe3yLims(1);
yBottom = handles.axe3yLims(2);
difference = yTop - yBottom;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
%newYTop = yBottom + frameSize;
newYBottom = yTop - frameSize;

% Updates what the new display values for y length should be!
set(handles.group3_axes, 'ylim', [yTop newYBottom]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider15_Callback(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of
%        slider

% This is the left (bottom) slider X-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider15, 'Value');
xRight = handles.axe4xLims(1);
xLeft = handles.axe4xLims(2);
difference = xLeft - xRight;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
newXRight = xRight + frameSize;
newXLeft = xLeft - frameSize;

% Updates what the new display values for x length should be!
set(handles.group4_axes, 'xlim', [newXLeft newXRight]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider16_Callback(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the left (bottom) slider Y-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider16, 'Value');
yTop = handles.axe4yLims(1);
yBottom = handles.axe4yLims(2);
difference = yTop - yBottom;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
%newYTop = yBottom + frameSize;
newYBottom = yTop - frameSize;

% Updates what the new display values for y length should be!
set(handles.group4_axes, 'ylim', [yTop newYBottom]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider17_Callback(hObject, eventdata, handles)
% hObject    handle to slider17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the middle (bottom) slider X-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This first if is ran once per new page, it sets the master values for
% future resets.  The else is ran anytime a new frame is needed for this
% particular axe.  Usually because of a shift.

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider17, 'Value');
xRight = handles.axe5xLims(1);
xLeft = handles.axe5xLims(2);
difference = xLeft - xRight;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
newXRight = xRight + frameSize;
newXLeft = xLeft - frameSize;

% Updates what the new display values for x length should be!
set(handles.group5_axes, 'xlim', [newXLeft newXRight]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider17_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider17 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider18_Callback(hObject, eventdata, handles)
% hObject    handle to slider18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This is the middle (bottom) slider X-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider18, 'Value');
yTop = handles.axe5yLims(1);
yBottom = handles.axe5yLims(2);
difference = yTop - yBottom;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
%newYTop = yBottom + frameSize;
newYBottom = yTop - frameSize;

% Updates what the new display values for y length should be!
set(handles.group5_axes, 'ylim', [yTop newYBottom]);

% Update handles structure
guidata(hObject, handles);

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider19_Callback(hObject, eventdata, handles)
% hObject    handle to slider19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the right (bottom) slider X-Zoom

% Checks the frames
frameTracker(hObject, handles);

% This first if is ran once per new page, it sets the master values for
% future resets.  The else is ran anytime a new frame is needed for this
% particular axe.  Usually because of a shift.

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider19, 'Value');
xRight = handles.axe6xLims(1);
xLeft = handles.axe6xLims(2);
difference = xLeft - xRight;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
newXRight = xRight + frameSize;
newXLeft = xLeft - frameSize;

% Updates what the new display values for x length should be!
set(handles.group6_axes, 'xlim', [newXLeft newXRight]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider20_Callback(hObject, eventdata, handles)
% hObject    handle to slider20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% This is the Right (bottom) slider Y-Zoom


% Checks the frames
frameTracker(hObject, handles);

% This section is the calculation for what the new values should be based
% on the slider's posision.
sliderValue = get(handles.slider20, 'Value');
yTop = handles.axe6yLims(1);
yBottom = handles.axe6yLims(2);
difference = yTop - yBottom;

newFrameCalc = sliderValue * difference;
frameSize = (2*(difference) - newFrameCalc) / 2;
%newYTop = yBottom + frameSize;
newYBottom = yTop - frameSize;

% Updates what the new display values for y length should be!
set(handles.group6_axes, 'ylim', [yTop newYBottom]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function group1_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group1_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate group1_axes


% --- Executes on button press in xZoomOut1_button.
function xZoomOut1_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Checks the frames

% This section is the calculation for what the new values should be based
% on the slider's posision.
xBounds = get(handles.group1_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToRemove = 0.02 * difference;
newXRight = xRight - amountToRemove/2;
newXLeft = xLeft + amountToRemove/2;

% Updates what the new display values for x length should be!
set(handles.group1_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in xZoomIn1_button.
function xZoomIn1_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new values should be based
% on the slider's posision.
xBounds = get(handles.group1_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToAdd = 0.02 * difference;
newXRight = xRight + amountToAdd/2;
newXLeft = xLeft - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group1_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in reset_xZoom1_button.
function reset_xZoom1_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.group1_axes,'xlim',getappdata(handles.figure1,'xlim_axes1'));


% --- Executes on button press in xZoomOut2_button.
function xZoomOut2_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in xZoomIn2_button.
function xZoomIn2_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in reset_xZoom2_button.
function reset_xZoom2_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
