function varargout = targeted_deconv_start(varargin)
% TARGETED_DECONV_START MATLAB code for targeted_deconv_start.fig
%      TARGETED_DECONV_START, by itself, creates a new TARGETED_DECONV_START or raises the existing
%      singleton*.
%
%      H = TARGETED_DECONV_START returns the handle to a new TARGETED_DECONV_START or the handle to
%      the existing singleton*.
%
%      TARGETED_DECONV_START('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TARGETED_DECONV_START.M with the given input arguments.
%
%      TARGETED_DECONV_START('Property','Value',...) creates a new TARGETED_DECONV_START or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before targeted_deconv_start_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to targeted_deconv_start_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help targeted_deconv_start

% Last Modified by GUIDE v2.5 25-Jul-2011 15:16:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @targeted_deconv_start_OpeningFcn, ...
                   'gui_OutputFcn',  @targeted_deconv_start_OutputFcn, ...
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


% --- Executes just before targeted_deconv_start is made visible.
function targeted_deconv_start_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to targeted_deconv_start (see VARARGIN)

% Choose default command line output for targeted_deconv_start
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes targeted_deconv_start wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = targeted_deconv_start_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles)
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function continue_filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to continue_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of continue_filename_box as text
%        str2double(get(hObject,'String')) returns contents of continue_filename_box as a double


% --- Executes during object creation, after setting all properties.
function continue_filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to continue_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in continue_browse_button.
function continue_browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to continue_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function collection_filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to collection_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of collection_filename_box as text
%        str2double(get(hObject,'String')) returns contents of collection_filename_box as a double


% --- Executes during object creation, after setting all properties.
function collection_filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to collection_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in collection_filename_browse_button.
function collection_filename_browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to collection_filename_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function collection_id_box_Callback(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to collection_id_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of collection_id_box as text
%        str2double(get(hObject,'String')) returns contents of collection_id_box as a double
v = str2double(get(hObject,'String'));
if length(v) ~= 1 || isnan(v)
    uiwait(msgbox('The collection id must be a number.','Error','error'));
    set(hObject,'String','Or enter collection id here');
end

% --- Executes during object creation, after setting all properties.
function collection_id_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to collection_id_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bin_map_filename_box_Callback(hObject, eventdata, handles)
% hObject    handle to bin_map_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of bin_map_filename_box as text
%        str2double(get(hObject,'String')) returns contents of bin_map_filename_box as a double


% --- Executes during object creation, after setting all properties.
function bin_map_filename_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bin_map_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bin_map_browse_button.
function bin_map_browse_button_Callback(hObject, eventdata, handles)
% hObject    handle to bin_map_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
