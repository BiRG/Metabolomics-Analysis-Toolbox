function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 06-Jul-2011 13:53:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in no_listbox.
function no_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to no_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns no_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from no_listbox

set(handles.yes_listbox,'Value',1);

no_inxs = find(handles.yes_mask == 0);
no_inx = get(hObject,'Value')-1;
if no_inx == 0
    set(handles.metabolite_info_edit,'String',{''});
    return;
end
inx = no_inxs(no_inx);
update_metabolite_information(handles,inx);

function update_metabolite_information(handles,inx)
set(handles.metabolite_info_edit,'String', ...
    handles.metabolites(inx).as_long_string);
xlim([handles.metabolites(inx).bin.right, ...
    handles.metabolites(inx).bin.left]);

% --- Executes during object creation, after setting all properties.
function no_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to no_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in yes_listbox.
function yes_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to yes_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns yes_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from yes_listbox

set(handles.no_listbox,'Value',1);

yes_inxs = find(handles.yes_mask == 1);
yes_inx = get(hObject,'Value')-1;
if yes_inx == 0
    set(handles.metabolite_info_edit,'String',{''});
    return;
end
inx = yes_inxs(yes_inx);
update_metabolite_information(handles,inx);

% --- Executes during object creation, after setting all properties.
function yes_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yes_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_pushbutton.
function add_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to add_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.all_checkbox,'Value')
    handles.yes_mask(:) = 1;
    refresh_both_lists(handles);
    set(handles.metabolite_info_edit,'String',{''});
else
    no_inx = get(handles.no_listbox,'Value')-1;
    if no_inx == 0
        return;
    end
    no_inxs = find(handles.yes_mask == 0);
    handles.yes_mask(no_inxs(no_inx)) = 1;
    refresh_both_lists(handles);
    yes_inxs = find(handles.yes_mask == 1);
    yes_inx = find(yes_inxs == no_inxs(no_inx));
    set(handles.yes_listbox,'Value',yes_inx+1);

    update_metabolite_information(handles,no_inxs(no_inx));
end

guidata(handles.figure1,handles);

% --- Executes on button press in remove_pushbutton.
function remove_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to remove_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if get(handles.all_checkbox,'Value')
    handles.yes_mask(:) = 0;
    refresh_both_lists(handles);
    set(handles.metabolite_info_edit,'String',{''});
else
    yes_inx = get(handles.yes_listbox,'Value')-1;
    if yes_inx == 0
        return;
    end
    yes_inxs = find(handles.yes_mask == 1);
    handles.yes_mask(yes_inxs(yes_inx)) = 0;
    refresh_both_lists(handles);
    no_inxs = find(handles.yes_mask == 0);
    no_inx = find(no_inxs == yes_inxs(yes_inx));
    set(handles.no_listbox,'Value',no_inx+1);

    update_metabolite_information(handles,yes_inxs(yes_inx));
end

guidata(handles.figure1,handles);

% --- Executes on button press in all_checkbox.
function all_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to all_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of all_checkbox


% --- Executes on button press in load_collection_pushbutton.
function load_collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


try
    collections = load_collections;
    if isempty(collections)
        return
    end
    if length(collections) > 1
        msgbox('Only load a single collection');
        return;
    end
    handles.collection = collections{1};
    
    clear_all(hObject,handles);
    
    set(handles.spectrum_listbox,'String',1:handles.collection.num_samples);
    xl = xlim;
    plot(handles.collection.x,handles.collection.Y(:,1));
    set(gca,'xdir','reverse');
    if xl(1) ~= 0 || xl(2) ~= 1
        xlim(xl);
    end    
    
    set(handles.description_text,'String',handles.collection.description);
    
    msgbox('Finished loading collection');
    
    % Update handles structure
    guidata(hObject, handles);
catch ME
    msgbox(strcat('Invalid collection.  Exception message: ',ME.message));
end

function collection_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to collection_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of collection_id_edit as text
%        str2double(get(hObject,'String')) returns contents of collection_id_edit as a double


% --- Executes during object creation, after setting all properties.
function collection_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to collection_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in get_pushbutton.
function get_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to get_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in spectrum_listbox.
function spectrum_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectrum_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spectrum_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectrum_listbox

contents = cellstr(get(hObject,'String'));
s_inx = str2num(contents{get(hObject,'Value')});

xl = xlim;
plot(handles.collection.x,handles.collection.Y(:,s_inx));
set(gca,'xdir','reverse');
if xl(1) ~= 0 || xl(2) ~= 1
    xlim(xl);
end

% --- Executes during object creation, after setting all properties.
function spectrum_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrum_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function reset_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xlim auto;
ylim auto;
xlim auto;


% --- Executes on button press in load_no_pushbutton.
function load_no_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_no_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.csv', 'Pick a metabolite map file');
if isequal(filename,0) || isequal(pathname,0)
   return;
end

handles.metabolites = load_metabmap(fullfile(pathname, filename),'no_deleted_bins');
handles.metabolites = sort_metabmap_by_name_then_ppm(handles.metabolites);
handles.yes_mask = zeros(1,length(handles.metabolites));
refresh_both_lists(handles);

guidata(hObject, handles);

function refresh_both_lists(handles)
refresh_list(handles.no_listbox,handles.metabolites,find(handles.yes_mask == 0));
refresh_list(handles.yes_listbox,handles.metabolites,find(handles.yes_mask == 1));

function refresh_list(h,metabolites,inxs)
names = {};
for i = 1:length(inxs)
    names{end+1} = metabolites(inxs(i)).compound_name;    
end
set(h,'String',{'',names{:}});
set(h,'Value',1);

% --- Executes on button press in load_yes_pushbutton.
function load_yes_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_yes_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_pushbutton.
function save_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uiputfile('*.csv', 'Pick a metabolite map file');
if isequal(filename,0) || isequal(pathname,0)
    return
end
yes_inxs = find(handles.yes_mask == 1);
save_metabmap(fullfile(pathname,filename), handles.metabolites(yes_inxs));

function metabolite_info_edit_Callback(hObject, eventdata, handles)
% hObject    handle to metabolite_info_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of metabolite_info_edit as text
%        str2double(get(hObject,'String')) returns contents of metabolite_info_edit as a double


% --- Executes during object creation, after setting all properties.
function metabolite_info_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metabolite_info_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
