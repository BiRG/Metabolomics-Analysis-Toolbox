function varargout = rebundlespectra(varargin)
% REBUNDLESPECTRA MATLAB code for rebundlespectra.fig
%      REBUNDLESPECTRA, by itself, creates a new REBUNDLESPECTRA or raises the existing
%      singleton*.
%
%      H = REBUNDLESPECTRA returns the handle to a new REBUNDLESPECTRA or the handle to
%      the existing singleton*.
%
%      REBUNDLESPECTRA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REBUNDLESPECTRA.M with the given input arguments.
%
%      REBUNDLESPECTRA('Property','Value',...) creates a new REBUNDLESPECTRA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before rebundlespectra_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to rebundlespectra_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help rebundlespectra

% Last Modified by GUIDE v2.5 05-Jul-2011 15:42:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @rebundlespectra_OpeningFcn, ...
                   'gui_OutputFcn',  @rebundlespectra_OutputFcn, ...
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


% --- Executes just before rebundlespectra is made visible.
function rebundlespectra_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to rebundlespectra (see VARARGIN)

% Choose default command line output for rebundlespectra
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes rebundlespectra wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = rebundlespectra_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in unused_list.
function unused_list_Callback(hObject, eventdata, handles)
% hObject    handle to unused_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns unused_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from unused_list


% --- Executes during object creation, after setting all properties.
function unused_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to unused_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in new_contents_list.
function new_contents_list_Callback(hObject, eventdata, handles)
% hObject    handle to new_contents_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns new_contents_list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from new_contents_list


% --- Executes during object creation, after setting all properties.
function new_contents_list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to new_contents_list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in use_spectrum_button.
function use_spectrum_button_Callback(hObject, eventdata, handles)
% hObject    handle to use_spectrum_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in stop_using_spectrum_button.
function stop_using_spectrum_button_Callback(hObject, eventdata, handles)
% hObject    handle to stop_using_spectrum_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in change_source_button.
function change_source_button_Callback(hObject, ~, handles)
% hObject    handle to change_source_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
collections = load_collections;
if isempty(collections) 
    return
end
handles.source_collection = collections{1};
set(handles.unused_list,'String',handles.source_collection.classification);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
