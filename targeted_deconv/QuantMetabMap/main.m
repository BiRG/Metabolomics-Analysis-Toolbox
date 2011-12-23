function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,~,handles,...) calls the local
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

% Last Modified by GUIDE v2.5 04-Oct-2011 11:22:17

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
function main_OpeningFcn(hObject, unused, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

% Set the uninitialized text box values (I do it here rather than in GUIDE
% so I am sure to have the same values when I check for uninitialized
% values - no possibility of changing it in GUIDE and 
% forgetting to change it in the done button or elsewhere I might need it.)
handles.uninitialized_metab_map_filename = 'Put filename here';
handles.uninitialized_collection_filename = 'Put filename here';
handles.uninitialized_collection_id = 'Or enter collection id here';
handles.uninitialized_continue_filename = 'Put saved session filename here';
set(handles.metab_map_filename_box, 'String', ...
    handles.uninitialized_metab_map_filename);
set(handles.collection_filename_box, 'String', ...
    handles.uninitialized_collection_filename);
set(handles.collection_id_box, 'String', ...
    handles.uninitialized_collection_id);
set(handles.continue_filename_box, 'String', ...
    handles.uninitialized_continue_filename);

% Set default metab-map filename to the last one loaded (if such a preference
% exists)
if ispref('Targeted_Deconvolution','last_metab_map_filename')
    set(handles.metab_map_filename_box,'String', ...
        getpref('Targeted_Deconvolution','last_metab_map_filename'));
end

%Set default collection filename if there is a preference for it and if the
%last load was from a file rather than from the website
if ispref('Targeted_Deconvolution','load_collection_from_file')
    if getpref('Targeted_Deconvolution','load_collection_from_file')
        if ispref('Targeted_Deconvolution','last_collection_filename')
            set(handles.collection_filename_box,'String', ...
                getpref('Targeted_Deconvolution', ...
                'last_collection_filename'));
        end
    else
        if ispref('Targeted_Deconvolution','last_collection_id_string')
            set(handles.collection_id_box, 'String', ...
                getpref('Targeted_Deconvolution', ...
                'last_collection_id_string'));
        end
    end
end

%Set default continuation filename to the last one loaded if there is a 
%preference for it
if ispref('Targeted_Deconvolution','last_continue_filename')
    set(handles.continue_filename_box,'String', ...
        getpref('Targeted_Deconvolution','last_continue_filename') );
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);hObject


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(unused, unused1, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function result = collection_id_is_initialized(handles)
% Returns true if the collection id box is initialized
result = contains_valid_collection_id(handles.collection_id_box);

function result = collection_filename_is_initialized(handles)
% Returns true if the collection filename box is initialized
result = contains_initialized_filename(handles.collection_filename_box, ...
    handles.uninitialized_collection_filename);

function result = metab_map_filename_is_initialized(handles)
% Returns true if the metab_map filename box is initialized
result = contains_initialized_filename(handles.metab_map_filename_box, ...
    handles.uninitialized_metab_map_filename);

function result = continue_filename_is_initialized(handles)
% Returns true if the continue filename box is initialized
result = contains_initialized_filename(handles.continue_filename_box, ...
    handles.uninitialized_continue_filename);

function result = contains_initialized_filename(box_handle, ...
    uninitialized_value)
% Returns true if the edit box given by box_handle contains an initialized
% filename.  An initialized filename 1) is not the empty string.
% 2) is not uninitialized_value.  and 3) exists.  I check for the first two
% to ensure that there won't be strange behavior if someone makes a file
% named something like 'Put filename here' on the matlab path.
s = get(box_handle, 'String');
result = ~strcmp(s, uninitialized_value) && ~strcmp(s, '') ...
    && exist(s, 'file');

function result=contains_valid_collection_id(box_handle)
% Returns true if the edit_box with the handle box_handle has a valid
% collection id as its string property
v = str2double(get(box_handle,'String'));
result = ~(length(v) ~= 1 || isnan(v));


% --- Executes on button press in done_button.
function done_button_Callback(unused, unused1, handles) %#ok<INUSL,DEFNU>
% hObject    handle to done_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset all preferences so it is easy to set new values on success
if ispref('Targeted_Deconvolution')
    rmpref('Targeted_Deconvolution'); 
end

% Try to continue a saved session
if continue_filename_is_initialized(handles)
    fn = get(handles.continue_filename_box,'String'); 
    setpref('Targeted_Deconvolution','last_continue_filename', fn);
    load(fn, '-mat','session_data');
    if exist('session_data','var')
        setappdata(0,'saved_session_data', session_data);
    else
        uiwait(msgbox('Could not read saved session data','Error','error'));
        set(handles.continue_filename_box,'String', ...
            handles.uninitialized_continue_filename);
        return;
    end
else

    % Failing that load the metab map and collection separately

    % Start by loading the metab map
    if ~metab_map_filename_is_initialized(handles)
        uiwait(msgbox('No valid metab map file was given.','Error','error'));
        return;
    end

    metab_map_filename = get(handles.metab_map_filename_box,'String');
    metab_map = load_metabmap(metab_map_filename,'no_deleted_bins');
    if isempty(metab_map)
        uiwait(msgbox('Could not read the metab map from the given file', ...
            'Error','error'));
        return;
    end
    setpref('Targeted_Deconvolution','last_metab_map_filename', ...
        metab_map_filename);
    metab_map = sort_metabmap_by_name_then_ppm(metab_map);


    % Now load the collection.  If there is a filename, load it from the
    % filename, otherwise, load it from the web site

    if collection_filename_is_initialized(handles)
        collection_filename = get(handles.collection_filename_box,'String');
        collections = load_collections_noninteractive({collection_filename},{''});
        if isempty(collections)
            return; %Error message already printed by load_collections_noninteractive
        end
        collection = collections{1};
        if ~isstruct(collection)
            return; %Error message already printed by load_collections_noninteractive
        end
        setpref('Targeted_Deconvolution','load_collection_from_file', 1);
        setpref('Targeted_Deconvolution','last_collection_filename', ...
            collection_filename);
    else
        if collection_id_is_initialized(handles)
            collection_id_str = get(handles.collection_id_box, 'String');
            collection_id = str2double(collection_id_str);
            [collection, message] = get_collection(collection_id);
            if isempty(collection)
                uiwait(msgbox(['Could not download collection #',...
                    collection_id_str, ':', message],'Error','error'));
                return;
            end
            setpref('Targeted_Deconvolution','load_collection_from_file', 0);
            setpref('Targeted_Deconvolution','last_collection_id_string', ...
                collection_id_str);
        else
            uiwait(msgbox(['You must either enter a valid collection id ',...
                'for the BIRG web site or a valid filename from which ',...
                'to load the spectrum collection.'],'Error','error'));
            return;
        end
    end

    %Pass the new data to the figure
    setappdata(0, 'collection', collection);
    setappdata(0, 'metab_map', metab_map);
end

%Start the new figure
targeted_identify;

%Close this dialog
delete(handles.figure1);


% --- Executes on button press in cancel_button.
function cancel_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes during object creation, after setting all properties.
function continue_filename_box_CreateFcn(hObject, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to continue_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in continue_browse_button.
function continue_browse_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to continue_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
       {'*.session', 'Saved session files (*.session)'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Select a saved session','MultiSelect', 'off');
    
if ~ischar(filename)
    return;
else
    fullpath=fullfile(pathname, filename);
    set(handles.continue_filename_box, 'String', fullpath);
end


% --- Executes during object creation, after setting all properties.
function collection_filename_box_CreateFcn(hObject, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to collection_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in collection_filename_browse_button.
function collection_filename_browse_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to collection_filename_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
       {'*.zip', 'Zip files (*.zip)'; ...
        '*.txt', 'Tab delimited files (*.txt)'; ...
        '*.*', 'All Files (*.*)'}, ...
        'Select a spectrum collection','MultiSelect', 'off');
    
if ~ischar(filename)
    return;
else
    fullpath=fullfile(pathname, filename);
    set(handles.collection_filename_box, 'String', fullpath);
    set(handles.collection_id_box,'String', ...
        handles.uninitialized_collection_id);
    set(handles.continue_filename_box,'String', ...
        handles.uninitialized_continue_filename);
end

function collection_id_box_Callback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to collection_id_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of collection_id_box as text
%        str2double(get(hObject,'String')) returns contents of collection_id_box as a double
if contains_valid_collection_id(hObject)
    set(handles.collection_filename_box,'String', ...
        handles.uninitialized_collection_filename);
    set(handles.continue_filename_box,'String', ...
        handles.uninitialized_continue_filename);
else
    uiwait(msgbox('The collection id must be a number.','Error','error'));
    set(hObject,'String',handles.uninitialized_collection_id);
end

% --- Executes during object creation, after setting all properties.
function collection_id_box_CreateFcn(hObject, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to collection_id_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function metab_map_filename_box_CreateFcn(hObject, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to metab_map_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in metab_map_browse_button.
function metab_map_browse_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to metab_map_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.csv','Select a metab map file');

if ~ischar(filename)
    return;
else
    fullpath=fullfile(pathname, filename);
    set(handles.metab_map_filename_box, 'String', fullpath);
    set(handles.continue_filename_box,'String', ...
        handles.uninitialized_continue_filename);
end



function metab_map_filename_box_Callback(hObject, unused1, handles) %#ok<INUSL,DEFNU>
% hObject    handle to metab_map_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: this function needs to be present even if blank - it will be called
%by the gui no matter what
fname = get(hObject, 'String');
if exist(fname, 'file')
    set(handles.continue_filename_box,'String', ...
        handles.uninitialized_continue_filename);
end
    

function collection_filename_box_Callback(hObject, unused1, handles) %#ok<INUSL,DEFNU>
% hObject    handle to collection_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: this function needs to be present even if blank - it will be called
%by the gui no matter what
fname = get(hObject, 'String');
if exist(fname, 'file')
    set(handles.continue_filename_box,'String', ...
        handles.uninitialized_continue_filename);
end


function continue_filename_box_Callback(unused2, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to continue_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: this function needs to be present even if blank - it will be called
%by the gui no matter what


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(unused2, unused1, unused0) %#ok<INUSD,DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
