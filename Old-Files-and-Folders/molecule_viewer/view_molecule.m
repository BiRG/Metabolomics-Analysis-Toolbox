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

% Last Modified by GUIDE v2.5 06-May-2010 14:47:46

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
handles.reset = false;

%Testing, may need changed.
handles.checkInitValues = 0;

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
show_molecule;

% --- Executes during object creation, after setting all properties.
function height_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height_slider (see GCBO)
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
function shift1_slider_Callback(hObject, eventdata, handles)
% hObject    handle to shift1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
show_molecule;
value = get(hObject,'Value');
mx = get(hObject,'Max');
mn = get(hObject,'Min');
halfway = (mn+mx)/2;
shift_allowance = str2num(get(handles.shift_allowance_edit,'String'));
shift = shift_allowance*(value - halfway);
xl = getappdata(handles.figure1,'xlim_axes1');
set(handles.group1_axes,'xlim',xl - shift);

% --- Executes during object creation, after setting all properties.
function shift1_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% --- Executes on slider movement.
function shift2_slider_Callback(hObject, eventdata, handles)
% hObject    handle to shift2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
show_molecule;
value = get(hObject,'Value');
mx = get(hObject,'Max');
mn = get(hObject,'Min');
halfway = (mn+mx)/2;
shift_allowance = str2num(get(handles.shift_allowance_edit,'String'));
shift = shift_allowance*(value - halfway);
xl = getappdata(handles.figure1,'xlim_axes2');
set(handles.group2_axes,'xlim',xl - shift);


% --- Executes during object creation, after setting all properties.
function shift2_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift2_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function shift3_slider_Callback(hObject, eventdata, handles)
% hObject    handle to shift3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
show_molecule;
value = get(hObject,'Value');
mx = get(hObject,'Max');
mn = get(hObject,'Min');
halfway = (mn+mx)/2;
shift_allowance = str2num(get(handles.shift_allowance_edit,'String'));
shift = shift_allowance*(value - halfway);
xl = getappdata(handles.figure1,'xlim_axes3');
set(handles.group3_axes,'xlim',xl - shift);


% --- Executes during object creation, after setting all properties.
function shift3_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift3_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function shift4_slider_Callback(hObject, eventdata, handles)
% hObject    handle to shift4_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
show_molecule;
value = get(hObject,'Value');
mx = get(hObject,'Max');
mn = get(hObject,'Min');
halfway = (mn+mx)/2;
shift_allowance = str2num(get(handles.shift_allowance_edit,'String'));
shift = shift_allowance*(value - halfway);
xl = getappdata(handles.figure1,'xlim_axes4');
set(handles.group4_axes,'xlim',xl - shift);


% --- Executes during object creation, after setting all properties.
function shift4_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift4_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function shift5_slider_Callback(hObject, eventdata, handles)
% hObject    handle to shift5_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
show_molecule;
value = get(hObject,'Value');
mx = get(hObject,'Max');
mn = get(hObject,'Min');
halfway = (mn+mx)/2;
shift_allowance = str2num(get(handles.shift_allowance_edit,'String'));
shift = shift_allowance*(value - halfway);
xl = getappdata(handles.figure1,'xlim_axes5');
set(handles.group5_axes,'xlim',xl - shift);


% --- Executes during object creation, after setting all properties.
function shift5_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift5_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function shift6_slider_Callback(hObject, eventdata, handles)
% hObject    handle to shift6_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
show_molecule;
value = get(hObject,'Value');
mx = get(hObject,'Max');
mn = get(hObject,'Min');
halfway = (mn+mx)/2;
shift_allowance = str2num(get(handles.shift_allowance_edit,'String'));
shift = shift_allowance*(value - halfway);
xl = getappdata(handles.figure1,'xlim_axes6');
set(handles.group6_axes,'xlim',xl - shift);

% --- Executes during object creation, after setting all properties.
function shift6_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to shift6_slider (see GCBO)
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

% This section is the calculation for what the new x limits should be.
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

% This section is the calculation for what the new x limits should be.
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

% Resets the zooms
set(handles.shift1_slider,'Value',1);
xlimits = getappdata(handles.figure1,'xlim_axes1');
set(handles.group1_axes, 'xlim', xlimits);
ylimits = getappdata(handles.figure1,'ylim_axes1');
set(handles.group1_axes, 'ylim', ylimits);

%Paul, changed to not need to call this.
%show_molecule;

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomOut2_button.
function xZoomOut2_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group2_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToRemove = 0.02 * difference;
newXRight = xRight - amountToRemove/2;
newXLeft = xLeft + amountToRemove/2;

% Updates what the new display values for x length should be!
set(handles.group2_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomIn2_button.
function xZoomIn2_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group2_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToAdd = 0.02 * difference;
newXRight = xRight + amountToAdd/2;
newXLeft = xLeft - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group2_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in reset_xZoom2_button.
function reset_xZoom2_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Resets the zooms
set(handles.shift2_slider,'Value',1);
xlimits = getappdata(handles.figure1,'xlim_axes2');
set(handles.group2_axes, 'xlim', xlimits);
ylimits = getappdata(handles.figure1,'ylim_axes2');
set(handles.group2_axes, 'ylim', ylimits);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomOut3_button.
function xZoomOut3_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group3_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToRemove = 0.02 * difference;
newXRight = xRight - amountToRemove/2;
newXLeft = xLeft + amountToRemove/2;

% Updates what the new display values for x length should be!
set(handles.group3_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomIn3_button.
function xZoomIn3_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group3_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToAdd = 0.02 * difference;
newXRight = xRight + amountToAdd/2;
newXLeft = xLeft - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group3_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in reset_xZoom3_button.
function reset_xZoom3_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Resets the zooms
set(handles.shift3_slider,'Value',1);
xlimits = getappdata(handles.figure1,'xlim_axes3');
set(handles.group3_axes, 'xlim', xlimits);
ylimits = getappdata(handles.figure1,'ylim_axes3');
set(handles.group3_axes, 'ylim', ylimits);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomOut4_button.
function xZoomOut4_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group4_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToRemove = 0.02 * difference;
newXRight = xRight - amountToRemove/2;
newXLeft = xLeft + amountToRemove/2;

% Updates what the new display values for x length should be!
set(handles.group4_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomIn4_button.
function xZoomIn4_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group4_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToAdd = 0.02 * difference;
newXRight = xRight + amountToAdd/2;
newXLeft = xLeft - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group4_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in reset_xZoom4_button.
function reset_xZoom4_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Resets the zooms
set(handles.shift4_slider,'Value',1);
xlimits = getappdata(handles.figure1,'xlim_axes4');
set(handles.group4_axes, 'xlim', xlimits);
ylimits = getappdata(handles.figure1,'ylim_axes4');
set(handles.group4_axes, 'ylim', ylimits);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomOut5_button.
function xZoomOut5_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group5_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToRemove = 0.02 * difference;
newXRight = xRight - amountToRemove/2;
newXLeft = xLeft + amountToRemove/2;

% Updates what the new display values for x length should be!
set(handles.group5_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomIn5_button.
function xZoomIn5_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group5_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToAdd = 0.02 * difference;
newXRight = xRight + amountToAdd/2;
newXLeft = xLeft - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group5_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in reset_xZoom5_button.
function reset_xZoom5_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Resets the zooms
set(handles.shift5_slider,'Value',1);
xlimits = getappdata(handles.figure1,'xlim_axes5');
set(handles.group5_axes, 'xlim', xlimits);
ylimits = getappdata(handles.figure1,'ylim_axes5');
set(handles.group5_axes, 'ylim', ylimits);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomOut6_button.
function xZoomOut6_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomOut6_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group6_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToRemove = 0.02 * difference;
newXRight = xRight - amountToRemove/2;
newXLeft = xLeft + amountToRemove/2;

% Updates what the new display values for x length should be!
set(handles.group6_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in xZoomIn6_button.
function xZoomIn6_button_Callback(hObject, eventdata, handles)
% hObject    handle to xZoomIn6_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This section is the calculation for what the new x limits should be.
xBounds = get(handles.group6_axes,'xlim');
xRight = xBounds(1);
xLeft = xBounds(2);
difference = xLeft - xRight;

amountToAdd = 0.02 * difference;
newXRight = xRight + amountToAdd/2;
newXLeft = xLeft - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group6_axes, 'xlim', [newXRight newXLeft]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in reset_xZoom6_button.
function reset_xZoom6_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_xZoom6_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Resets the zooms
set(handles.shift6_slider,'Value',1);
xlimits = getappdata(handles.figure1,'xlim_axes6');
set(handles.group6_axes, 'xlim', xlimits);
ylimits = getappdata(handles.figure1,'ylim_axes6');
set(handles.group6_axes, 'ylim', ylimits);

% Update handles structure
guidata(hObject, handles);


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over xZoomIn1_button.
function xZoomIn1_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to xZoomIn1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in yZoomOut1_button.
function yZoomOut1_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomOut1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group1_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop + amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group1_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomIn1_button.
function yZoomIn1_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomIn1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% This section is the calculation for what the new x limits should be.

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group1_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group1_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in reset_yZoom1_button.
function reset_yZoom1_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_yZoom1_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in yZoomOut2_button.
function yZoomOut2_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomOut2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group2_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop + amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group2_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomIn2_button.
function yZoomIn2_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomIn2_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group2_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group2_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomOut3_button.
function yZoomOut3_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomOut3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group3_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop + amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group3_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomIn3_button.
function yZoomIn3_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomIn3_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group3_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group3_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomOut4_button.
function yZoomOut4_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomOut4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group4_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop + amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group4_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomIn4_button.
function yZoomIn4_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomIn4_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group4_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group4_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomOut5_button.
function yZoomOut5_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomOut5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group5_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop + amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group5_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomIn5_button.
function yZoomIn5_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomIn5_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group5_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group5_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomOut6_button.
function yZoomOut6_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomOut6_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group6_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop + amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group6_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in yZoomIn6_button.
function yZoomIn6_button_Callback(hObject, eventdata, handles)
% hObject    handle to yZoomIn6_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This calculates a new upper bounds for the axe.
yBounds = get(handles.group6_axes,'ylim');
yBottom = yBounds(1);
yTop = yBounds(2);
difference = yTop - yBottom;

amountToAdd = .5 * difference;
newYTop = yTop - amountToAdd/2;

% Updates what the new display values for x length should be!
set(handles.group6_axes, 'ylim', [yBottom newYTop]);

% Update handles structure
guidata(hObject, handles);

% --- Executes during object deletion, before destroying properties.
function shift1_slider_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to shift1_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in decrease_height_button.
function decrease_height_button_Callback(hObject, eventdata, handles)
% hObject    handle to decrease_height_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

height = getappdata(handles.figure1,'height');
height = height*0.95;
setappdata(handles.figure1,'height',height);
show_molecule;

% --- Executes on button press in increase_height_button.
function increase_height_button_Callback(hObject, eventdata, handles)
% hObject    handle to increase_height_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

height = getappdata(handles.figure1,'height');
height = height*1.05;
setappdata(handles.figure1,'height',height);
show_molecule;

% --- Executes on button press in reset_height_button.
function reset_height_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_height_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

setappdata(handles.figure1,'height',getappdata(handles.figure1,'init_height'));
show_molecule;


% --- Executes on button press in load_collections_button.
% function load_collections_button_Callback(hObject, eventdata, handles)
% % hObject    handle to load_collections_button (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% collections = load_collections;
% [x,Y,labels] = combine_collections(collections);
% view_molecule_handles = guidata(view_molecule);
% setappdata(view_molecule_handles.figure1,'x',x);
% setappdata(view_molecule_handles.figure1,'Y',Y);
% set(view_molecule_handles.height_slider,'Min',0);
% set(view_molecule_handles.height_slider,'Max',max(max(Y)));
% set(view_molecule_handles.height_slider,'Value',mean(mean(Y)));
% setappdata(view_molecule_handles.figure1,'sample_inx',1);
% % Now compute the peak list
% left_noise = 10; % Needs to be user-defined later
% right_noise = 9.3; % Needs to be user-defined later
% if right_noise > left_noise
%     t = left_noise;
%     left_noise = right_noise;
%     right_noise = t;
% end
% h_options = options;
% opts = get_options(h_options);
% close(h_options);
% spectra = create_spectra(x,Y,left_noise,right_noise,opts);
% setappdata(view_molecule_handles.figure1,'spectra',spectra);
% show_molecule;
% 
% % Saves the modified versions of Y coordinates.  X is not changed.
% setappdata(handles.figure1,'ylim_axes1',get(handles.group1_axes,'ylim'));
% setappdata(handles.figure1,'ylim_axes2',get(handles.group2_axes,'ylim'));
% setappdata(handles.figure1,'ylim_axes3',get(handles.group3_axes,'ylim'));
% setappdata(handles.figure1,'ylim_axes4',get(handles.group4_axes,'ylim'));
% setappdata(handles.figure1,'ylim_axes5',get(handles.group5_axes,'ylim'));
% setappdata(handles.figure1,'ylim_axes6',get(handles.group6_axes,'ylim'));
% 
% % Update handles structure
% guidata(hObject, handles);
