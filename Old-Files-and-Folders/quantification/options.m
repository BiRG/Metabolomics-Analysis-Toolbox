function varargout = options(varargin)
% OPTIONS M-file for options.fig
%      OPTIONS, by itself, creates a new OPTIONS or raises the existing
%      singleton*.
%
%      H = OPTIONS returns the handle to a new OPTIONS or the handle to
%      the existing singleton*.
%
%      OPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OPTIONS.M with the given input arguments.
%
%      OPTIONS('Property','Value',...) creates a new OPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before options_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to options_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help options

% Last Modified by GUIDE v2.5 04-Feb-2010 15:53:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @options_OpeningFcn, ...
                   'gui_OutputFcn',  @options_OutputFcn, ...
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


% --- Executes just before options is made visible.
function options_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to options (see VARARGIN)

% Choose default command line output for options
handles.output = hObject;

set(handles.peak_height_percentile_edit,'String',num2str(100));
set(handles.tptr_listbox,'String',{'rigrsure','heursure','sqtwolog','minimaxi'});
set(handles.tptr_listbox,'Value',1);
set(handles.level_edit,'String',1);
set(handles.sorh_listbox,'String',{'s','h'});
set(handles.sorh_listbox,'Value',1);
set(handles.scal_listbox,'String',{'one','sln','mln'});
set(handles.scal_listbox,'Value',1);
wnames = {'haar'};
dbixs = 2;
for ix = 1:length(dbixs)
    dbix = dbixs(ix);
    wnames{end+1} = ['db',num2str(dbix)];
end
coifixs = 1:5;
for ix = 1:length(coifixs)
    coifix = coifixs(ix);
    wnames{end+1} = ['coif',num2str(coifix)];
end
symixs = 2:8;
for ix = 1:length(symixs)
    symix = symixs(ix);
    wnames{end+1} = ['sym',num2str(symix)];
end
set(handles.wavelet_listbox,'String',wnames);
set(handles.wavelet_listbox,'Value',13);
set(handles.noise_std_edit,'String','5');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes options wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = options_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function R2_threshold_edit_Callback(hObject, eventdata, handles)
% hObject    handle to R2_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of R2_threshold_edit as text
%        str2double(get(hObject,'String')) returns contents of R2_threshold_edit as a double


% --- Executes during object creation, after setting all properties.
function R2_threshold_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to R2_threshold_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tptr_listbox.
function tptr_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to tptr_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns tptr_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tptr_listbox


% --- Executes during object creation, after setting all properties.
function tptr_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tptr_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in sorh_listbox.
function sorh_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to sorh_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns sorh_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sorh_listbox


% --- Executes during object creation, after setting all properties.
function sorh_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sorh_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scal_listbox.
function scal_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to scal_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns scal_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scal_listbox


% --- Executes during object creation, after setting all properties.
function scal_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scal_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function level_edit_Callback(hObject, eventdata, handles)
% hObject    handle to level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of level_edit as text
%        str2double(get(hObject,'String')) returns contents of level_edit as a double


% --- Executes during object creation, after setting all properties.
function level_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wavelet_listbox.
function wavelet_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns wavelet_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wavelet_listbox


% --- Executes during object creation, after setting all properties.
function wavelet_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelet_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_std_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_std_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_std_edit as a double


% --- Executes during object creation, after setting all properties.
function noise_std_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function peak_height_percentile_edit_Callback(hObject, eventdata, handles)
% hObject    handle to peak_height_percentile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peak_height_percentile_edit as text
%        str2double(get(hObject,'String')) returns contents of peak_height_percentile_edit as a double


% --- Executes during object creation, after setting all properties.
function peak_height_percentile_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_height_percentile_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


