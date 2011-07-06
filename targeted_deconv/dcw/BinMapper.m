function varargout = BinMapper(varargin)
% BINMAPPER MATLAB code for BinMapper.fig
%      BINMAPPER, by itself, creates a new BINMAPPER or raises the existing
%      singleton*.
%
%      H = BINMAPPER returns the handle to a new BINMAPPER or the handle to
%      the existing singleton*.
%
%      BINMAPPER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BINMAPPER.M with the given input arguments.
%
%      BINMAPPER('Property','Value',...) creates a new BINMAPPER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BinMapper_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BinMapper_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BinMapper

% Last Modified by GUIDE v2.5 06-Jul-2011 15:29:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BinMapper_OpeningFcn, ...
                   'gui_OutputFcn',  @BinMapper_OutputFcn, ...
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


% --- Executes just before BinMapper is made visible.
function BinMapper_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BinMapper (see VARARGIN)

% Choose default command line output for BinMapper
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Add shared MATLAB scripts to the path
addpath('../../matlab_scripts');

% UIWAIT makes BinMapper wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BinMapper_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Delete the 'collections' variable.
% -- DCW -- collectionsLoadChk = evalin('base', 'exist(''collections'', ''var'')');
% -- DCW -- if ( collectionsLoadChk == 1 )
% -- DCW --     evalin('base', 'delete collections');
% -- DCW -- end;


% --- Executes during object creation, after setting all properties.
function select_collection_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_collection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;


% --- Executes during object creation, after setting all properties.
function select_spectra_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_spectra_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;


% --- Executes on button press in load_collection_button.
function load_collection_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_collection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

axes(handles.axes1);

% Fetch the spectra from flatfiles
handles.collections = load_collections();
msgbox('Finished loading collection');
guidata(hObject, handles);

% Set the spectral display radio buttons to default
set(handles.individual_mode_radiobutton,'Value', ...
    get(handles.individual_mode_radiobutton,'Max'));

if ( ~isempty(handles.collections) )
    cla;
    % Build the select collection popup string
    collectionCount = length(handles.collections);
    collectionPopupStr = '|'; % Include a blank line @ top
    for i = 1:collectionCount
        one_filename = handles.collections{i}.filename;
        collectionPopupStr = [collectionPopupStr, one_filename];
    end;
    finalStrLen = length(collectionPopupStr);
    if (finalStrLen > 1)
        collectionPopupStr = collectionPopupStr(1:finalStrLen-1); % Drop the extra pipe char.
    end;
    set(handles.select_collection_popup,'String',collectionPopupStr);
    set(handles.select_collection_popup,'Enable','on');
    set(handles.select_spectra_popup,'String','^ Select a collection first');
    set(handles.select_spectra_popup,'Enable','off');
else
    set(handles.select_collection_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_collection_popup,'Enable','off');
    set(handles.select_spectra_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_spectra_popup,'Enable','off');
end;


% --- Executes on selection change in select_collection_popup.
function select_collection_popup_Callback(hObject, eventdata, handles)
% hObject    handle to select_collection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_collection_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_collection_popup
popupCollectionNum = get(hObject, 'Value');
spectralDispMode = get(handles.individual_mode_radiobutton, 'Value');
if ( spectralDispMode == get(handles.individual_mode_radiobutton, 'Max') )
    % We are in individual spectrum display mode
    
    if ( popupCollectionNum > 1 )
        
        % Populate the spectra popup menu with the contents of the
        % collection.
        set(handles.select_spectra_popup,'Enable','on');
        sampleCount = ...
            handles.collections{popupCollectionNum-1}.num_samples;
        sampleIDsStr = '';
        if ( isnumeric(handles.collections{popupCollectionNum-1}.sample_id{1}) )
            for i = 1:sampleCount
                sampleIDsStr = [sampleIDsStr, ...
                    num2str(handles.collections{popupCollectionNum-1}.sample_id{i}, '%d'), '|'];
            end;
        else
            for i = 1:sampleCount
                sampleIDsStr = [sampleIDsStr, num2str(i, '%d'), '|'];
            end;
        end;
        finalStrLen = length(sampleIDsStr);
        if ( finalStrLen > 1 )
            sampleIDsStr = sampleIDsStr(1:finalStrLen-1); % Drop the extra pipe char.
        end;
        set(handles.select_spectra_popup, 'String', sampleIDsStr);

    else

        % Blank line was selected on collection popup menu. Disable spectra
        % popup.
        set(handles.select_spectra_popup, 'String', '^ Select a collection first');
        set(handles.select_spectra_popup, 'Enable', 'off');
    end;
else

    % Not in individual mode. Populate the graph with all spectra overlaid.
end;


% --- Executes on selection change in select_spectra_popup.
function select_spectra_popup_Callback(hObject, eventdata, handles)
% hObject    handle to select_spectra_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_spectra_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_spectra_popup
popupCollectionNum = get(handles.select_collection_popup, 'Value');
popupSpectraNum = get(hObject, 'Value');


% --- Executes when selected object is changed in spectra_display_mode_uipanel.
function spectra_display_mode_uipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in spectra_display_mode_uipanel 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    case 'overlaid_mode_radiobutton'
        % Display all spectra in the collection as an overlay.
        set(handles.select_spectra_popup,'Enable','off'); % Disable the spectra popup menu.
    case 'individual_mode_radiobutton'
        % Display only one spectra in the collection at a time.
        popupCollectionNum = get(handles.select_collection_popup, 'Value');
        if ( popupCollectionNum > 1 )
            set(handles.select_spectra_popup,'Enable','on');
        else
            set(handles.select_spectra_popup,'Enable','off');
        end;
    otherwise
        set(eventdata.NewValue,'Tag','individual_mode_radiobutton')
end;


% --- Executes on button press in load_binmap_button.
function load_binmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_binmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_binmap_button.
function save_binmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_binmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
