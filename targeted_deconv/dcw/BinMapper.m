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

% Last Modified by GUIDE v2.5 13-Jul-2011 12:16:13

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
addpath('../../common_scripts');

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
% handles    empty - handles not created until after all CreateFcns called
axes(handles.axes1);
cla;


% --- Draws all stored bins, the working bin, and the currently selected
%     spectrum (or all spectra if the mode is Overlay).
function redrawGraph(handles)
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
if ( isfield(handles, 'workingLeftBound') )
    xseries = [handles.workingLeftBound handles.workingLeftBound];
    plot(xseries, axesObjLimit, '-.g');
end;
if ( isfield(handles, 'workingRightBound') )
    xseries = [handles.workingRightBound handles.workingRightBound];
    plot(xseries, axesObjLimit, '-.r');
end;

% Draw all stored bin bounds.
if ( isfield(handles, 'storedBinsLeftBounds') )
    for i = 1:length(handles.storedBinsLeftBounds)
        xseries = ...
            [ handles.storedBinsLeftBounds(i) ...
            handles.storedBinsLeftBounds(i) ];
        plot(xseries, axesObjLimit, 'Color', [.67 1 1], 'LineStyle', '-.');
        xseries = ...
            [ handles.storedBinsRightBounds(i) ...
            handles.storedBinsRightBounds(i) ];
        plot(xseries, axesObjLimit, 'Color', [1 .67 0], 'LineStyle', '-.');
    end;
end;

hold off;


% --- Fill the Mapped Bins listbox on the GUI
function repopulateMappedBinsList(handles)
% handles    structure with handles and user data (see GUIDATA)
stringPropCell = '';
if (handles.currentStoredBinCount == 1)
    stringPropCell = [ num2str(handles.storedBinsIDs, '%d') ',' ...
        handles.storedBinsMetabolites{1} ',' ...
        num2str(handles.storedBinsLeftBounds, '%.3f') ',' ...
        num2str(handles.storedBinsRightBounds, '%.3f') ];
else
    stringPropCell = {};
    for i = 1:handles.currentStoredBinCount
        stringPropCell{i} = [ num2str(handles.storedBinsIDs(i), '%d') ',' ...
            handles.storedBinsMetabolites{i} ',' ...
            num2str(handles.storedBinsLeftBounds(i), '%.3f') ',' ...
            num2str(handles.storedBinsRightBounds(i), '%.3f') ];
    end;
end;
set(handles.mapped_bins_listbox, 'String', stringPropCell);


% --- Executes during object creation, after setting all properties.
function select_collection_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_collection_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;


% --- Executes during object creation, after setting all properties.
function select_spectrum_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to select_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;


% --- Executes during object creation, after setting all properties.
function mapped_bins_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mapped_bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function metabolite_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metabolite_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function left_bound_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to left_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function right_bound_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to right_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function id_source_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to id_source_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function deconvolution_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to deconvolution_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function multiplicity_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to multiplicity_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function proton_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to proton_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
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
if ( ~isempty(handles.collections) )
    msgbox('Finished loading collection', 'Action Complete', ...
        'help', 'modal');
end;

% Set spectral display radio buttons & bin management buttons to default.
set(handles.individual_mode_radiobutton,'Value', ...
    get(handles.individual_mode_radiobutton,'Max'));
set(handles.append_bin_button, 'Enable', 'off');
set(handles.retrieve_bin_button, 'Enable', 'off');
set(handles.delete_bin_button, 'Enable', 'off');
clearGraph(handles);

if ( ~isempty(handles.collections) )
    
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
    set(handles.left_bound_mode_radiobutton, 'Enable', 'on');
    set(handles.right_bound_mode_radiobutton, 'Enable', 'on');
else
    set(handles.select_collection_popup, 'Value', 1);
    set(handles.select_collection_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_collection_popup,'Enable','off');
    set(handles.select_spectrum_popup, 'Value', 1);
    set(handles.select_spectrum_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_spectrum_popup,'Enable','off');
    set(handles.left_bound_mode_radiobutton,'Enable','off');
    set(handles.right_bound_mode_radiobutton,'Enable','off');
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
        set(handles.append_bin_button, 'Enable', 'on');
        set(handles.retrieve_bin_button, 'Enable', 'on');
        set(handles.delete_bin_button, 'Enable', 'on');
        
    else
        
        % User has switched out of individual mode.
        % Disable the spectra popup.
        set(handles.select_spectrum_popup, 'Enable', 'off');
        set(handles.append_bin_button, 'Enable', 'off');
        set(handles.retrieve_bin_button, 'Enable', 'off');
        set(handles.delete_bin_button, 'Enable', 'off');
    end;
    
    redrawGraph(handles);
else
    
    % Blank line was selected on collection popup menu. Disable spectra
    % popup, append button, & clear the axes
    clearGraph(handles);
    set(handles.select_spectrum_popup, 'Value', 1); % Surpresses a warning & popup bug.
    set(handles.select_spectrum_popup, 'String', '^ Select a collection first');
    set(handles.select_spectrum_popup, 'Enable', 'off');
    set(handles.append_bin_button, 'Enable', 'off');
    set(handles.retrieve_bin_button, 'Enable', 'off');
    set(handles.delete_bin_button, 'Enable', 'off');
end;


% --- Executes on selection change in select_spectrum_popup.
function select_spectrum_popup_Callback(hObject, eventdata, handles)
% hObject    handle to select_spectrum_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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
        % Disable the spectra popup menu & do not allow bin appending.
        set(handles.select_spectrum_popup, 'Enable', 'off');
        set(handles.append_bin_button, 'Enable', 'off');
        redrawGraph(handles);
        
    case 'individual_mode_radiobutton'
        % Display only one spectrum in the collection at a time.
        if ( popupCollectionNum > 0 )
            % A collection is selected.
            set(handles.select_spectrum_popup, 'Enable', 'on');
            set(handles.append_bin_button, 'Enable', 'on');
            set(handles.retrieve_bin_button, 'Enable', 'on');
            set(handles.delete_bin_button, 'Enable', 'on');
            redrawGraph(handles);
        else
            % No collection is actually selected to display.
            set(handles.select_spectrum_popup, 'Enable', 'off');
            set(handles.append_bin_button, 'Enable', 'off');
            set(handles.retrieve_bin_button, 'Enable', 'off');
            set(handles.delete_bin_button, 'Enable', 'off');
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
[filename, pathname] = uigetfile( ...
    {'*.txt;*.csv', 'Tab/comma delimited files (*.txt, *.csv)'; ...
    '*.*', 'All Files (*.*)'} );
if ( ~isempty(filename) )
    fid = fopen([pathname filename]);
    handles.binmapHeaders = textscan(fid, ...
        '%q %q %q %q %q %q %q %q', 1, ...
        'Delimiter', ',\t');
    binmapData = textscan(fid, '%d %q %f %f %q %q %q %q', ...
        'Delimiter', ',\t');
    fclose(fid);
    handles.storedBinsIDs = binmapData{1};
    handles.currentStoredBinCount = length(handles.storedBinsIDs);
    handles.storedBinsMetabolites = binmapData{2};
    handles.storedBinsLeftBounds = binmapData{3};
    handles.storedBinsRightBounds = binmapData{4};
    handles.storedBinsMultiplicities = binmapData{5};
    handles.storedBinsDeconv = binmapData{6};
    handles.storedBinsProtonIDs = binmapData{7};
    handles.storedBinsIDSources = binmapData{8};
    
    % -- DCW: TODO: Add collection and spectrum ID to format
    handles.storedBinsCollectionID = ...
        zeros(handles.currentStoredBinCount, 1);
    handles.storedBinsSpectrumID = ...
        zeros(handles.currentStoredBinCount, 1);
    
    guidata(hObject, handles);
    repopulateMappedBinsList(handles);
    
    % A collection has already been loaded and selected. Redraw.
    if ( isfield(handles, 'collections') && ...
            ~isempty(handles.collections) && ...
            get(handles.select_collection_popup, 'Value') > 1 )
        redrawGraph(handles);
    end;
    
    msgbox('Finished loading Binmap', 'Action Complete', ...
        'help', 'modal');
else
    msgbox('No binmap opened.', 'Warning', 'warn', 'modal');
end;


% --- Executes on button press in retrieve_bin_button.
function retrieve_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to retrieve_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% -- DCW: TODO: Zoom in on bin @ retrieval.
selectedBin = get(handles.mapped_bins_listbox, 'Value');
set(handles.metabolite_name_edit, 'String', ...
    handles.storedBinsMetabolites{selectedBin});
set(handles.id_source_edit, 'String', ...
    handles.storedBinsIDSources{selectedBin});
set(handles.proton_id_edit, 'String', ...
    handles.storedBinsProtonIDs{selectedBin});
set(handles.deconvolution_edit, 'String', ...
    handles.storedBinsDeconv{selectedBin});
set(handles.left_bound_edit, 'String', ...
    num2str(handles.storedBinsLeftBounds(selectedBin),'%.5e'));
set(handles.right_bound_edit, 'String', ...
    num2str(handles.storedBinsRightBounds(selectedBin),'%.5e'));
set(handles.multiplicity_edit, 'String', ...
    handles.storedBinsMultiplicities{selectedBin});
handles.workingLeftBound = handles.storedBinsLeftBounds(selectedBin);
handles.workingRightBound = handles.storedBinsRightBounds(selectedBin);
guidata(hObject, handles);


% --- Executes on button press in delete_bin_button.
function delete_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Feature not yet implemented.', ...
    'Under Construction', 'warn', 'modal');

% --- Executes on button press in save_binmap_button.
function save_binmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_binmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% -- DCW: TODO: Correctly escape or otherwise handle string fields which
%               contain commas or other delimiting characters.
targetfile = '';
[filename, pathname] = uiputfile( ...
    {'*.txt;*.csv', 'Tab/comma delimited files (*.txt, *.csv)'; ...
    '*.*', 'All Files (*.*)'} );
if ( ~isequal(filename, 0) && ~isequal(pathname, 0) )
    targetfile = fullfile(pathname,filename);
    [fid message] = fopen(targetfile, 'w');
    if ( fid > 0 )
        fprintf(fid, ['ID,Metabolite,Bin (Lt),Bin (Rt),multiplicity,'...
            'Deconvolution,Proton ID,ID Source\n']);
        for i = 1:handles.currentStoredBinCount
            fprintf(fid, '%d,%s,%.8e,%.8e,%s,%s,%s,%s\n', ...
                handles.storedBinsIDs(i), ...
                handles.storedBinsMetabolites{i}, ...
                handles.storedBinsLeftBounds(i), ...
                handles.storedBinsRightBounds(i), ...
                handles.storedBinsMultiplicities{i}, ...
                handles.storedBinsDeconv{i}, ...
                handles.storedBinsProtonIDs{i}, ...
                handles.storedBinsIDSources{i});
        end;
        fclose(fid);
    end;
end;


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
    boundMode = get(handles.right_bound_mode_radiobutton, 'Value');
    if ( boundMode == get(handles.right_bound_mode_radiobutton, 'Max') )
        % User has selected right x bound.
        handles.workingRightBound = clickXCoord;
        set(handles.right_bound_edit, 'String', num2str(clickXCoord,'%.5e'));
    else
        % User has selected left x bound.
        handles.workingLeftBound = clickXCoord;
        set(handles.left_bound_edit, 'String', num2str(clickXCoord,'%.5e'));
    end;
    guidata(hObject, handles);
    redrawGraph(handles);
    
end;


function left_bound_edit_Callback(hObject, eventdata, handles)
% hObject    handle to left_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[userLeftBound, convResult] = str2num(get(hObject,'String'));
if ( convResult )
    % Update GUI & data.
    handles.workingLeftBound = userLeftBound;
    guidata(hObject, handles);
    redrawGraph(handles);
else
    % Non-numeric value entered into the left bound field.
end;


function right_bound_edit_Callback(hObject, eventdata, handles)
% hObject    handle to right_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[userRightBound, convResult] = str2num(get(hObject,'String'));
if ( convResult )
    % Update GUI & data.
    handles.workingRightBound = userRightBound;
    guidata(hObject, handles);
    redrawGraph(handles);
else
    % Non-numeric value entered into the right bound field.
end;


% --- Executes on button press in append_bin_button.
function append_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to append_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ( isfield(handles, 'storedBinsIDs') )
    nextBinID = max(handles.storedBinsIDs)+1;
    handles.currentStoredBinCount = handles.currentStoredBinCount+1;
    handles.storedBinsIDs(handles.currentStoredBinCount) = nextBinID;
    handles.storedBinsMetabolites{handles.currentStoredBinCount} = ...
        get(handles.metabolite_name_edit, 'String');
    handles.storedBinsLeftBounds(handles.currentStoredBinCount) = ...
        str2num(get(handles.left_bound_edit, 'String'));
    handles.storedBinsRightBounds(handles.currentStoredBinCount) = ...
        str2num(get(handles.right_bound_edit, 'String'));
    handles.storedBinsMultiplicities{handles.currentStoredBinCount} = ...
        get(handles.multiplicity_edit, 'String');
    handles.storedBinsDeconv{handles.currentStoredBinCount} = ...
        get(handles.deconvolution_edit, 'String');
    handles.storedBinsProtonIDs{handles.currentStoredBinCount} = ...
        get(handles.proton_id_edit, 'String');
    handles.storedBinsIDSources{handles.currentStoredBinCount} = ...
        get(handles.id_source_edit, 'String');
    handles.storedBinsCollectionID(handles.currentStoredBinCount) = ...
        0; % -- DCW: For later tracking.
    handles.storedBinsSpectrumID(handles.currentStoredBinCount) = ...
        0; % -- DCW: For later tracking.
else
    nextBinID = 1;
    handles.currentStoredBinCount = 1;
    handles.storedBinsIDs = nextBinID;
    handles.storedBinsMetabolites = {};
    handles.storedBinsMetabolites{1} = ...
        get(handles.metabolite_name_edit, 'String');
    handles.storedBinsLeftBounds = ...
        str2num(get(handles.left_bound_edit, 'String'));
    handles.storedBinsRightBounds = ...
        str2num(get(handles.right_bound_edit, 'String'));
    handles.storedBinsMultiplicities = {};
    handles.storedBinsMultiplicities{1} = ...
        get(handles.multiplicity_edit, 'String');
    handles.storedBinsDeconv = {};
    handles.storedBinsDeconv{1} = ...
        get(handles.deconvolution_edit, 'String');
    handles.storedBinsProtonIDs = {};
    handles.storedBinsProtonIDs{1} = ...
        get(handles.proton_id_edit, 'String');
    handles.storedBinsIDSources = {};
    handles.storedBinsIDSources{1} = ...
        get(handles.id_source_edit, 'String');
    handles.storedBinsCollectionID = ...
        0; % -- DCW: For later tracking.
    handles.storedBinsSpectrumID = ...
        0; % -- DCW: For later tracking.
end;
guidata(hObject, handles);
repopulateMappedBinsList(handles);


% -- DCW: Spare callbacks & other hooks


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in mapped_bins_listbox.
function mapped_bins_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to mapped_bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function metabolite_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to metabolite_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of metabolite_name_edit as text
%        str2double(get(hObject,'String')) returns contents of metabolite_name_edit as a double


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
