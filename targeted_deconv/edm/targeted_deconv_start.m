function varargout = targeted_deconv_start(varargin)
% TARGETED_DECONV_START MATLAB code for targeted_deconv_start.fig
%      TARGETED_DECONV_START, by itself, creates a new TARGETED_DECONV_START or raises the existing
%      singleton*.
%
%      H = TARGETED_DECONV_START returns the handle to a new TARGETED_DECONV_START or the handle to
%      the existing singleton*.
%
%      TARGETED_DECONV_START('CALLBACK',hObject,~,handles,...) calls the local
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

% Last Modified by GUIDE v2.5 26-Jul-2011 12:29:56

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
function targeted_deconv_start_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to targeted_deconv_start (see VARARGIN)

% Choose default command line output for targeted_deconv_start
handles.output = hObject;

% Set the uninitialized text box values (I do it here rather than in GUIDE
% so I am sure to have the same values when I check for uninitialized
% values - no possibility of changing it in GUIDE and 
% forgetting to change it in the done button or elsewhere I might need it.)
handles.uninitialized_bin_map_filename = 'Put filename here';
handles.uninitialized_collection_filename = 'Put filename here';
handles.uninitialized_collection_id = 'Or enter collection id here';
handles.uninitialized_continue_filename = 'Put saved session filename here';
set(handles.bin_map_filename_box, 'String', ...
    handles.uninitialized_bin_map_filename);
set(handles.collection_filename_box, 'String', ...
    handles.uninitialized_collection_filename);
set(handles.collection_id_box, 'String', ...
    handles.uninitialized_collection_id);
set(handles.continue_filename_box, 'String', ...
    handles.uninitialized_continue_filename);

% Set default bin-map filename to the last one loaded (if such a preference
% exists)
if ispref('Targeted_Deconvolution','last_bin_map_filename')
    set(handles.bin_map_filename_box,'String', ...
        getpref('Targeted_Deconvolution','last_bin_map_filename'));
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

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes targeted_deconv_start wait for user response (see UIRESUME)
% uiwait(handles.figure1);hObject


% --- Outputs from this function are returned to the command line.
function varargout = targeted_deconv_start_OutputFcn(~, ~, handles) 
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

function result = bin_map_filename_is_initialized(handles)
% Returns true if the bin_map filename box is initialized
result = contains_initialized_filename(handles.bin_map_filename_box, ...
    handles.uninitialized_bin_map_filename);

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
function done_button_Callback(~, ~, handles) %#ok<DEFNU>
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

    % Failing that load the bin map and collection separately

    % Start by loading the bin map
    if ~bin_map_filename_is_initialized(handles)
        uiwait(msgbox('No valid bin map file was given.','Error','error'));
        return;
    end

    bin_map_filename = get(handles.bin_map_filename_box,'String');
    bin_map = load_binmap(bin_map_filename);
    if isempty(bin_map)
        uiwait(msgbox('Could not read the bin map from the given file', ...
            'Error','error'));
        return;
    end
    setpref('Targeted_Deconvolution','last_bin_map_filename', ...
        bin_map_filename);


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
    setappdata(0, 'bin_map', bin_map);
end

%Start the new figure
targeted_identify;

%Close this dialog
delete(handles.figure1);


% --- Executes on button press in cancel_button.
function cancel_button_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
delete(handles.figure1);

% --- Executes during object creation, after setting all properties.
function continue_filename_box_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to continue_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in continue_browse_button.
function continue_browse_button_Callback(~, ~, handles) %#ok<DEFNU>
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
function collection_filename_box_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to collection_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in collection_filename_browse_button.
function collection_filename_browse_button_Callback(~, ~, handles) %#ok<DEFNU>
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
end

function collection_id_box_Callback(hObject, ~, handles) %#ok<DEFNU>
% hObject    handle to collection_id_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of collection_id_box as text
%        str2double(get(hObject,'String')) returns contents of collection_id_box as a double
if contains_valid_collection_id(hObject)
    set(handles.collection_filename_box,'String', ...
        handles.uninitialized_collection_filename);
else
    uiwait(msgbox('The collection id must be a number.','Error','error'));
    set(hObject,'String',handles.uninitialized_collection_id);
end

% --- Executes during object creation, after setting all properties.
function collection_id_box_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to collection_id_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function bin_map_filename_box_CreateFcn(hObject, ~, ~) %#ok<DEFNU>
% hObject    handle to bin_map_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bin_map_browse_button.
function bin_map_browse_button_Callback(~, ~, handles) %#ok<DEFNU>
% hObject    handle to bin_map_browse_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.csv','Select a bin map file');

if ~ischar(filename)
    return;
else
    fullpath=fullfile(pathname, filename);
    set(handles.bin_map_filename_box, 'String', fullpath);
end



function bin_map_filename_box_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to bin_map_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: this function needs to be present even if blank - it will be called
%by the gui no matter what


function collection_filename_box_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to collection_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: this function needs to be present even if blank - it will be called
%by the gui no matter what


function continue_filename_box_Callback(~, ~, ~) %#ok<DEFNU>
% hObject    handle to continue_filename_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%NOTE: this function needs to be present even if blank - it will be called
%by the gui no matter what