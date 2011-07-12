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

% Last Modified by GUIDE v2.5 12-Jul-2011 17:56:47

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


% --- Clears the main axes object.
function clearGraph(handles)
% hObject    handle to select_spectrum_popup (see GCBO)
% handles    empty - handles not created until after all CreateFcns called
axes(handles.axes1);
cla;


% --- Draws all stored bins, the working bin, and the currently selected
%     spectrum (or all spectra if the mode is Overlay).
function redrawGraph(handles)
% hObject    handle to select_spectrum_popup (see GCBO)
% handles    empty - handles not created until after all CreateFcns called

popupCollectionNum = get(handles.select_collection_popup, 'Value') - 1; % Popup entries are 1-indexed.
popupSpectrumNum = get(handles.select_spectrum_popup, 'Value');
spectralDispMode = get(handles.individual_mode_radiobutton, 'Value');

clearGraph(handles);

axes(handles.axes1);
hold on;
if ( isfield(handles, 'collections') && ~isempty(handles.collections)...
        && popupCollectionNum > 0 )
    % At least one collection has been loaded & selected. Proceed.
    
    if ( spectralDispMode == get(handles.individual_mode_radiobutton, 'Max') )
        
        % We are in individual spectrum display mode.
        % Draw the selected spectrum.
        plot(handles.collections{popupCollectionNum}.x, ...
            handles.collections{popupCollectionNum}.Y(:,popupSpectrumNum));
        
    else
        
        % Not in individual mode. Populate the graph with all spectra
        % overlaid and disable the spectra popup.
        plot(handles.collections{popupCollectionNum}.x, ...
            handles.collections{popupCollectionNum}.Y);
    end;
end;

% Fetch the y-axis limits for the axes object. This bounds the top and
% bottom of the bin boundaries.
axesObjLimit = get(handles.axes1, 'YLim');

% Draw the working bin bounds, if appropriate.
if ( isfield(handles, 'workingLowerBound') )
    xseries = [handles.workingLowerBound handles.workingLowerBound];
    plot(xseries, axesObjLimit, '-.g');
end;
if ( isfield(handles, 'workingUpperBound') )
    xseries = [handles.workingUpperBound handles.workingUpperBound];
    plot(xseries, axesObjLimit, '-.r');
end;

% Draw all stored bin bounds.
% TODO DCW

hold off;


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


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
function select_spectrum_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;


% --- Executes during object creation, after setting all properties.
function mapped_bins_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapped_bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function metabolite_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metabolite_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function lower_bound_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lower_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function upper_bound_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to upper_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function id_source_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to id_source_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function deconvolution_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deconvolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function multiplicity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to multiplicity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function proton_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to proton_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_collection_button.
function load_collection_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_collection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Fetch the spectra from flatfiles.
handles.collections = load_collections();
guidata(hObject, handles);
msgbox('Finished loading collection', 'Action Complete', 'help', 'modal');

% Set the spectral display radio buttons to default.
set(handles.individual_mode_radiobutton,'Value', ...
    get(handles.individual_mode_radiobutton,'Max'));

if ( ~isempty(handles.collections) )
    
    clearGraph(handles);
    
    % Build the select collection popup string.
    collectionCount = length(handles.collections);
    collectionPopupStr = '|'; % Include a blank line @ top
    for i = 1:collectionCount
        one_filename = handles.collections{i}.filename;
        collectionPopupStr = [collectionPopupStr, one_filename, '|'];
    end;
    finalStrLen = length(collectionPopupStr);
    if (finalStrLen > 1)
        collectionPopupStr = collectionPopupStr(1:finalStrLen-1); % Drop the extra pipe char.
    end;
    set(handles.select_collection_popup, 'Value', 1);
    set(handles.select_collection_popup, 'String', collectionPopupStr);
    set(handles.select_collection_popup, 'Enable', 'on');
    set(handles.select_spectrum_popup, 'Value', 1);
    set(handles.select_spectrum_popup, 'String', '^ Select a collection first');
    set(handles.select_spectrum_popup, 'Enable', 'off');
    set(handles.lower_bound_mode_radiobutton, 'Enable', 'on');
    set(handles.upper_bound_mode_radiobutton, 'Enable', 'on');
else
    set(handles.select_collection_popup, 'Value', 1);
    set(handles.select_collection_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_collection_popup,'Enable','off');
    set(handles.select_spectrum_popup, 'Value', 1);
    set(handles.select_spectrum_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_spectrum_popup,'Enable','off');
    set(handles.lower_bound_mode_radiobutton,'Enable','off');
    set(handles.upper_bound_mode_radiobutton,'Enable','off');
end;


% --- Executes on selection change in select_collection_popup.
function select_collection_popup_Callback(hObject, eventdata, handles)
% hObject    handle to select_collection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

popupCollectionNum = get(hObject, 'Value') - 1; % Popup entries are 1-indexed.
spectralDispMode = get(handles.individual_mode_radiobutton, 'Value');

if ( popupCollectionNum > 0 )
    % A collection has been selected. Populate the spectra popup menu with
    % the contents of the collection.
    set(handles.select_spectrum_popup,'Enable','on');
    sampleCount = ...
        handles.collections{popupCollectionNum}.num_samples;
    spectraIDsStr = '';
    for i = 1:sampleCount
        spectraIDsStr = [spectraIDsStr, num2str(i, '%d'), '|'];
    end;
    finalStrLen = length(spectraIDsStr);
    if ( finalStrLen > 1 ) % Make sure we don't try to trim from an empty spectra list.
        spectraIDsStr = spectraIDsStr(1:finalStrLen-1); % Drop the extra pipe char.
    end;
    set(handles.select_spectrum_popup, 'String', spectraIDsStr);
    
    if ( spectralDispMode == get(handles.individual_mode_radiobutton, 'Max') )
        
        % User has switched to individual spectrum display mode.
        % Enable the spectrum popup and select first spectrum.
        set(handles.select_spectrum_popup, 'Enable', 'on');
        set(handles.select_spectrum_popup, 'Value', 1);
        
    else
        
        % User has switched out of individual mode.
        % Disable the spectra popup.
        set(handles.select_spectrum_popup, 'Enable', 'off');
    end;
    
    redrawGraph(handles);
else
    
    % Blank line was selected on collection popup menu. Disable spectra
    % popup & clear the axes
    clearGraph(handles);
    set(handles.select_spectrum_popup, 'Value', 1); % Surpresses a warning & popup bug.
    set(handles.select_spectrum_popup, 'String', '^ Select a collection first');
    set(handles.select_spectrum_popup, 'Enable', 'off');
end;


% --- Executes on selection change in select_spectrum_popup.
function select_spectrum_popup_Callback(hObject, eventdata, handles)
% hObject    handle to select_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns select_spectrum_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from select_spectrum_popup

redrawGraph(handles);

% --- Executes when selected object is changed in spectra_display_mode_uipanel.
function spectra_display_mode_uipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in spectra_display_mode_uipanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

popupCollectionNum = get(handles.select_collection_popup, 'Value') - 1; % Popup entries are 1-indexed.

switch get(eventdata.NewValue,'Tag') % Get Tag of selected object.
    
    case 'overlaid_mode_radiobutton'
        % Disable the spectra popup menu.
        set(handles.select_spectrum_popup,'Enable','off');
        redrawGraph(handles);
        
    case 'individual_mode_radiobutton'
        % Display only one spectra in the collection at a time.
        if ( popupCollectionNum > 0 )
            set(handles.select_spectrum_popup,'Enable','on');
            redrawGraph(handles);
        else
            set(handles.select_spectrum_popup,'Enable','off');
        end;
        
    otherwise
        % Make sure the individual mode is selected.
        set(eventdata.NewValue,'Tag','individual_mode_radiobutton');
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


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
popupCollectionNum = get(handles.select_collection_popup, 'Value') - 1; % Popup entries are 1-indexed.
if ( isfield(handles, 'collections') && ~isempty(handles.collections)...
        && popupCollectionNum > 0 )
    
    % A collection has been loaded and selected.
    clickCoords = get(gca,'CurrentPoint');
    clickXCoord = clickCoords(1,1);
    boundMode = get(handles.upper_bound_mode_radiobutton, 'Value');
    if ( boundMode == get(handles.upper_bound_mode_radiobutton, 'Max') )
        % User has selected upper x bound.
        handles.workingUpperBound = clickXCoord;
        set(handles.upper_bound_edit, 'String', num2str(clickXCoord,'%.4e'));
    else
        % User has selected lower x bound.
        handles.workingLowerBound = clickXCoord;
        set(handles.lower_bound_edit, 'String', num2str(clickXCoord,'%.4e'));
    end;
    guidata(hObject, handles);
    redrawGraph(handles);

end;


% --- Executes on button press in append_bin_button.
function append_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to append_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in mapped_bins_listbox.
function mapped_bins_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to mapped_bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns mapped_bins_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from mapped_bins_listbox


function metabolite_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to metabolite_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of metabolite_name_edit as text
%        str2double(get(hObject,'String')) returns contents of metabolite_name_edit as a double


function lower_bound_edit_Callback(hObject, eventdata, handles)
% hObject    handle to lower_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lower_bound_edit as text
%        str2double(get(hObject,'String')) returns contents of lower_bound_edit as a double
[userLowerBound, convResult] = str2num(get(hObject,'String'));
if ( convResult )
    % Update GUI & data.
    handles.workingLowerBound = userLowerBound;
    guidata(hObject, handles);
    redrawGraph(handles);
else
    % Non-numeric value entered into the lower bound field.
end;


function upper_bound_edit_Callback(hObject, eventdata, handles)
% hObject    handle to upper_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of upper_bound_edit as text
%        str2double(get(hObject,'String')) returns contents of upper_bound_edit as a double
[userUpperBound, convResult] = str2num(get(hObject,'String'));
if ( convResult )
    % Update GUI & data.
    handles.workingUpperBound = userUpperBound;
    guidata(hObject, handles);
    redrawGraph(handles);
else
    % Non-numeric value entered into the upper bound field.
end;


function id_source_edit_Callback(hObject, eventdata, handles)
% hObject    handle to id_source_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of id_source_edit as text
%        str2double(get(hObject,'String')) returns contents of id_source_edit as a double


function deconvolution_edit_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of deconvolution_edit as text
%        str2double(get(hObject,'String')) returns contents of deconvolution_edit as a double


function multiplicity_edit_Callback(hObject, eventdata, handles)
% hObject    handle to multiplicity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of multiplicity_edit as text
%        str2double(get(hObject,'String')) returns contents of multiplicity_edit as a double


function proton_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to proton_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of proton_id_edit as text
%        str2double(get(hObject,'String')) returns contents of proton_id_edit as a double

