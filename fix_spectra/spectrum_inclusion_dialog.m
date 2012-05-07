function varargout = spectrum_inclusion_dialog(varargin)
% SPECTRUM_INCLUSION_DIALOG MATLAB code for spectrum_inclusion_dialog.fig
%      SPECTRUM_INCLUSION_DIALOG, by itself, creates a new SPECTRUM_INCLUSION_DIALOG or raises the existing
%      singleton*.
%
%      H = SPECTRUM_INCLUSION_DIALOG returns the handle to a new SPECTRUM_INCLUSION_DIALOG or the handle to
%      the existing singleton*.
%
%      SPECTRUM_INCLUSION_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SPECTRUM_INCLUSION_DIALOG.M with the given input arguments.
%
%      SPECTRUM_INCLUSION_DIALOG('Property','Value',...) creates a new SPECTRUM_INCLUSION_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before spectrum_inclusion_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to spectrum_inclusion_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help spectrum_inclusion_dialog

% Last Modified by GUIDE v2.5 07-May-2012 13:17:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @spectrum_inclusion_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @spectrum_inclusion_dialog_OutputFcn, ...
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


% --- Executes just before spectrum_inclusion_dialog is made visible.
function spectrum_inclusion_dialog_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to spectrum_inclusion_dialog (see VARARGIN)

% Choose default command line output for spectrum_inclusion_dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes spectrum_inclusion_dialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = spectrum_inclusion_dialog_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in add_all_button.
function add_all_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to add_all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in remove_all_button.
function remove_all_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to remove_all_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in add_button.
function add_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to add_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in remove_button.
function remove_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to remove_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in field_name_popup.
function field_name_popup_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to field_name_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns field_name_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from field_name_popup


% --- Executes during object creation, after setting all properties.
function field_name_popup_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to field_name_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in field_value_popup.
function field_value_popup_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to field_value_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns field_value_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from field_value_popup


% --- Executes during object creation, after setting all properties.
function field_value_popup_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to field_value_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in done_button.
function done_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
