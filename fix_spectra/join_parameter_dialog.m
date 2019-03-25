function varargout = join_parameter_dialog(varargin)
% JOIN_PARAMETER_DIALOG MATLAB code for join_parameter_dialog.fig
%      JOIN_PARAMETER_DIALOG, by itself, creates a new JOIN_PARAMETER_DIALOG or raises the existing
%      singleton*.
%
%      H = JOIN_PARAMETER_DIALOG returns the handle to a new JOIN_PARAMETER_DIALOG or the handle to
%      the existing singleton*.
%
%      JOIN_PARAMETER_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in JOIN_PARAMETER_DIALOG.M with the given input arguments.
%
%      JOIN_PARAMETER_DIALOG('Property','Value',...) creates a new JOIN_PARAMETER_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before join_parameter_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to join_parameter_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help join_parameter_dialog

% Last Modified by GUIDE v2.5 28-Feb-2019 22:03:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @join_parameter_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @join_parameter_dialog_OutputFcn, ...
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


% --- Executes just before join_parameter_dialog is made visible.
function join_parameter_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to join_parameter_dialog (see VARARGIN)

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes join_parameter_dialog wait for user response (see UIRESUME)
% uiwait(handles.join_parameter_dialog);
handles.collections = varargin{1};
populate_listboxes(handles);
set_value_popupmenus(handles);
guidata(handles.join_parameter_dialog, handles);
uiwait(handles.join_parameter_dialog);


% --- Outputs from this function are returned to the command line.
function varargout = join_parameter_dialog_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% Jeez this is a convoluted way to get a value from a selector :(
label_string = get(handles.filter_popupmenu, 'String');
pos_label = label_string{get(handles.filter_popupmenu, 'Value')};
neg_label = pos_label;
pos_string = get(handles.positive_value_popupmenu, 'String');
pos_value = pos_string{get(handles.positive_value_popupmenu, 'Value')};
neg_string = get(handles.negative_value_popupmenu, 'String');
neg_value = neg_string{get(handles.negative_value_popupmenu, 'Value')};
join_string = get(handles.join_listbox, 'String');
join_label = {};
join_inds = get(handles.join_listbox, 'Value');
for li = 1:length(join_inds)
    join_label{end+1} = join_string{join_inds(li)};
end


varargout{1} = struct('pos_label', pos_label, ...
                      'neg_label', neg_label, ...
                      'pos_value', pos_value, ...
                      'neg_value', neg_value, ...
                      'join_label', join_label);
delete(hObject);


% --- Executes on selection change in join_listbox.
function join_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to join_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns join_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from join_listbox


% --- Executes during object creation, after setting all properties.
function join_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to join_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in filter_popupmenu.
function filter_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to filter_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns filter_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from filter_popupmenu
handles = guidata(handles.join_parameter_dialog);
set_value_popupmenus(handles);


function set_value_popupmenus(handles)
items = get(handles.filter_popupmenu, 'String');
selected_ind = get(handles.filter_popupmenu, 'Value');
selected_field = items{selected_ind};
unique_vals = unique(convert_to_cell(handles.collections{1}.(selected_field)));
for c = 1:length(handles.collections)
    unique_vals = unique(horzcat(unique_vals, convert_to_cell(handles.collections{c}.(selected_field))));
end
set(handles.positive_value_popupmenu, 'String', unique_vals);
set(handles.negative_value_popupmenu, 'String', unique_vals);


% --- Executes during object creation, after setting all properties.
function filter_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filter_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in positive_value_popupmenu.
function positive_value_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to positive_value_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns positive_value_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from positive_value_popupmenu


% --- Executes during object creation, after setting all properties.
function positive_value_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to positive_value_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in negative_value_popupmenu.
function negative_value_popupmenu_Callback(hObject, eventdata, handles)
% hObject    handle to negative_value_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns negative_value_popupmenu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from negative_value_popupmenu


% --- Executes during object creation, after setting all properties.
function negative_value_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to negative_value_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok_button.
function ok_button_Callback(hObject, eventdata, handles)
% hObject    handle to ok_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close();


function populate_listboxes(handles)
input_fields = intersect(fields(handles.collections{1}), fields(handles.collections{2}));
valid_fields = {};
for f = 1:length(input_fields)
    input_field = input_fields{f};
    valid = 0;
    for c = 1:length(handles.collections)
        [m, n] = size(handles.collections{c}.(input_field));
        if (m == 1) && (n == size(handles.collections{c}.Y, 2))
            valid = 1;
        else
            valid = 0;
            break;
        end
    end
    if valid
        valid_fields{end+1} = input_field;
    end
end
valid_fields = sort(valid_fields);
set(handles.filter_popupmenu, 'String', valid_fields);
set(handles.join_listbox, 'String', valid_fields);
set(handles.join_listbox, 'Max', length(valid_fields) - 1);


% --- Executes when user attempts to close join_parameter_dialog.
function join_parameter_dialog_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to join_parameter_dialog (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, call UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

function converted = convert_to_cell(input)
    if isnumeric(input)
        converted = cellfun(@(v){num2str(v(1))}, num2cell(input));
    else
        converted = input;
    end
