function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the
%      existing singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the
%      handle to the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the
%      local function named CALLBACK in MAIN.M with the given input
%      arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or
%      raises the existing singleton*.  Starting from the left, property
%      value pairs are applied to the GUI before main_OpeningFcn
%      gets called.  An unrecognized property name or invalid value makes
%      property application stop.  All inputs are passed to
%      main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 04-Oct-2011 15:57:27

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

% Add shared MATLAB scripts to the path
addpath('../../common_scripts');

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


% --- Clears the main axes object.
function clearGraph(handles)
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;


% --- Draws all stored bins, the working bin, and the currently selected
%     spectrum (or all spectra if the mode is Overlay).
function redrawGraph(handles)
% handles    structure with handles and user data (see GUIDATA)
popupCollectionNum = get(handles.select_collection_popup, 'Value') - 1; % Popup entries are 1-indexed.
popupSpectrumNum = get(handles.select_spectrum_popup, 'Value');
spectralDispMode = get(handles.individual_mode_radiobutton, 'Value');

clearGraph(handles);

axes(handles.axes1);
hold on;
if ( isfield(handles, 'collections') && ~isempty(handles.collections)...
        && popupCollectionNum > 0 )
    % At least one collection has been loaded & selected. Proceed.
    
    if ( spectralDispMode == ...
            get(handles.individual_mode_radiobutton, 'Max') )
        
        % We are in individual spectrum display mode.
        % Draw the selected spectrum.
        plot(handles.collections{popupCollectionNum}.x, ...
            handles.collections{popupCollectionNum}.Y(:,popupSpectrumNum));
        
    else if ( spectralDispMode == ...
                get(handles.overlaid_mode_radiobutton, 'Max') )
            
            % We are in overlay mode. Populate the graph with all spectra
            % overlaid.
            plot(handles.collections{popupCollectionNum}.x, ...
                handles.collections{popupCollectionNum}.Y);
            
        else
            
            % We are in selective display mode. Populate the graph with only
            % the selected spectra overlaid.
            msgbox('Selected spectral overlay feature not yet implemented', ...
                'Oops!');
            %        plot(handles.collections{popupCollectionNum}.x, ...
            %            handles.collections{popupCollectionNum}.Y);
            
        end;
    end;
end;

% Fetch the y-axis limits for the axes object. This bounds the top and
% bottom of the bin boundaries.
axesObjLimit = get(handles.axes1, 'YLim');

% Draw the working bin bounds, if appropriate.
if ( isfield(handles, 'workingLeftBound') )
    xseries = [handles.workingLeftBound handles.workingLeftBound];
    plot(xseries, axesObjLimit, '-.g', 'LineWidth', 2);
end;
if ( isfield(handles, 'workingRightBound') )
    xseries = [handles.workingRightBound handles.workingRightBound];
    plot(xseries, axesObjLimit, '-.r', 'LineWidth', 2);
end;

% Draw all stored bin bounds.
if ( isfield(handles, 'storedBins') )
    for i = 1:length(handles.storedBins)
        xseries = [ handles.storedBins(i).bin.left ...
            handles.storedBins(i).bin.left ];
        plot(xseries, axesObjLimit, ...
            'Color', [.67 1 1], ...
            'LineStyle', '-.');
        xseries = [ handles.storedBins(i).bin.right ...
            handles.storedBins(i).bin.right ];
        plot(xseries, axesObjLimit, ...
            'Color', [1 .67 0], ...
            'LineStyle', '-.');
    end;
end;

hold off;


% --- Fill the Mapped Bins listbox on the GUI
function repopulateMappedBinsList(handles)
% handles    structure with handles and user data (see GUIDATA)
stringPropCell = '';
if ( isfield(handles, 'storedBins') )
    storedBinsArrayLen = length(handles.storedBins);
    %if ( storedBinsArrayLen == 1 )
    %    stringPropCell = [ num2str(handles.storedBins.id, '%d') ',' ...
    %        handles.storedBins.compound_name ',' ...
    %        num2str(handles.storedBins.bin.left, '%.3f') ',' ...
    %        num2str(handles.storedBins.bin.right, '%.3f') ];
    %else
    stringPropCell = {};
    for i = 1:storedBinsArrayLen
        if ( ~handles.storedBins(i).was_deleted )
            stringPropCell{i} = [ ...
                num2str(handles.storedBins(i).id, '%d') ',' ...
                handles.storedBins(i).compound_name ',' ...
                num2str(handles.storedBins(i).bin.left, '%.3f') ',' ...
                num2str(handles.storedBins(i).bin.right, '%.3f') ];
        end;
    end;
    %end;
end;
set(handles.mapped_bins_listbox, 'String', stringPropCell);


% --- Fill the Metabolite selection dropdown menu on the GUI
function repopulateMetabolitePopup(handles)
% handles    structure with handles and user data (see GUIDATA)
if ( isfield(handles, 'storedBins') )
    menuOptionCellAr = { ...
        ''; ...
        '* Add a new metabolite... *'; ...
        '** Metabolite Unknown... **' };
    menuOptionCellAr = [ menuOptionCellAr; ...
        handles.metaboliteIDNameTable(:,2) ];
    set(handles.metabolite_name_popup, 'String', menuOptionCellAr);
end;


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


% --- Executes during object creation, after setting all properties.
function hmdb_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to hmdb_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function metabolite_name_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metabolite_name_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function new_metab_name_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to new_metab_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function peak_count_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to peak_count_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function selected_display_spectra_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selected_display_spectra_edit (see GCBO)
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
if ( ~isempty(handles.collections) )
    msgbox('Finished loading collection', 'Action Complete', ...
        'help', 'modal');
end;

% Set spectral display radio buttons & bin display
% management buttons to their defaults.
set(handles.individual_mode_radiobutton,'Value', ...
    get(handles.individual_mode_radiobutton,'Max'));
set(handles.append_bin_button, 'Enable', 'off');
set(handles.retrieve_bin_button, 'Enable', 'off');
clearGraph(handles);

% Rechecking to allow for some operations to occur after the user
% has been notified of the successful collection load.
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
        
    else
        
        % User has switched out of individual mode.
        % Disable the spectra popup.
        set(handles.select_spectrum_popup, 'Enable', 'off');
        set(handles.append_bin_button, 'Enable', 'off');
        set(handles.retrieve_bin_button, 'Enable', 'off');
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
        % Disable the spectrum select popup menu & do not allow bin
        % appending as we're displaying all the spectra at once.
        set(handles.select_spectrum_popup, 'Enable', 'off');
        set(handles.append_bin_button, 'Enable', 'off');
        redrawGraph(handles);
        
    case 'individual_mode_radiobutton'
        % We intend to display only one spectrum in the
        % collection at a time. Allow bin appending and
        % enable the spectrum select popup.
        if ( popupCollectionNum > 0 )
            % A collection is selected.
            set(handles.select_spectrum_popup, 'Enable', 'on');
            set(handles.append_bin_button, 'Enable', 'on');
            set(handles.retrieve_bin_button, 'Enable', 'on');
            redrawGraph(handles);
        else
            % No collection is actually selected to display.
            set(handles.select_spectrum_popup, 'Enable', 'off');
            set(handles.append_bin_button, 'Enable', 'off');
            set(handles.retrieve_bin_button, 'Enable', 'off');
        end;
        
    case 'some_mode_radiobutton'
        % We intend to display a reduced set of overlaid spectra.
        % Allow bin appending but disable the spectrum select popup.
        if ( popupCollectionNum > 0 )
            % A collection is selected.
            set(handles.select_spectrum_popup, 'Enable', 'off');
            set(handles.append_bin_button, 'Enable', 'on');
            set(handles.retrieve_bin_button, 'Enable', 'on');
            redrawGraph(handles);
        else
            % No collection is actually selected to display.
            set(handles.select_spectrum_popup, 'Enable', 'off');
            set(handles.append_bin_button, 'Enable', 'off');
            set(handles.retrieve_bin_button, 'Enable', 'off');
        end;
        
    otherwise
        % Make sure the individual mode is selected.
        set(eventdata.NewValue,'Tag','individual_mode_radiobutton');
end;


% --- Executes on button press in load_metabmap_button.
function load_metabmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_metabmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, pathname] = uigetfile( ...
    {'*.txt;*.csv', 'Tab/comma delimited files (*.txt, *.csv)'; ...
    '*.*', 'All Files (*.*)'} );
if ( ischar(filename) && ~isempty(filename) )
    %    fid = fopen([pathname filename]);
    %    handles.binmapHeaders = textscan(fid, ...
    %        '%q %q %q %q %q %q %q %q %q %q %q', 1, ...
    %        'Delimiter', ',\t');
    %    binmapData = textscan(fid, '%d %d %q %f %f %q %q %q %d %q %q', ...
    %        'Delimiter', ',\t');
    %    fclose(fid);
    %    handles.storedBinsMetabIDs = binmapData{1};
    %    handles.currentStoredBinCount = length(handles.storedBinsMetabIDs);
    %    handles.storedBinsPeakNums = binmapData{2};
    %    handles.storedBinsMetabolites = binmapData{3};
    %    handles.storedBinsLeftBounds = binmapData{4};
    %    handles.storedBinsRightBounds = binmapData{5};
    %    handles.storedBinsMultiplicities = binmapData{6};
    %    handles.storedBinsDeconv = binmapData{7};
    %    handles.storedBinsProtonIDs = binmapData{8};
    %    handles.storedBinsHmdbIDs = binmapData{9};
    %    handles.storedBinsChenomx = binmapData{10};
    %    handles.storedBinsSources = binmapData{11};
    
    handles.storedBins = load_metabmap(fullfile(pathname, filename));
    
    % -- DCW: TODO: Add collection and spectrum ID to format
    %    handles.storedBinsCollectionID = ...
    %        zeros(handles.currentStoredBinCount, 1);
    %    handles.storedBinsSpectrumID = ...
    %        zeros(handles.currentStoredBinCount, 1);
    
    guidata(hObject, handles);
    repopulateMappedBinsList(handles);
    
    % Prep the metabolite lookup table for population.
    storedBinsArrayLen = length(handles.storedBins);
    tempIDNameTable = cell(storedBinsArrayLen, 1);
    for i=1:storedBinsArrayLen
        tempIDNameTable{i} = ...
            [ lower(handles.storedBins(i).compound_name) '<%$#>' ...
            num2str(handles.storedBins(i).compound_id) ];
    end;
    tempIDNameTable = unique(tempIDNameTable);
    tempIDNameTable = ...
        regexp(unique(tempIDNameTable), ...
        '^(.+)<%\$#>(\d+)$', 'tokens', 'once');
    handles.metaboliteIDNameTable = { ...
        ['-3'] ''; ...
        ['-2'] '* Add a new metabolite... *'; ...
        ['-1'] '** Metabolite Unknown... **' };
    for i=1:length(tempIDNameTable)
        handles.metaboliteIDNameTable = ...
            [ handles.metaboliteIDNameTable ; ...
            {tempIDNameTable{i}{2} tempIDNameTable{i}{1}} ];
    end;
    guidata(hObject, handles);
    set(handles.metabolite_name_popup, 'String', ...
        handles.metaboliteIDNameTable(:,2));
    
    % A collection has already been loaded and selected. Redraw graph.
    if ( isfield(handles, 'collections') && ...
            ~isempty(handles.collections) && ...
            get(handles.select_collection_popup, 'Value') > 1 )
        redrawGraph(handles);
    end;
    
    set(handles.delete_bin_button, 'Enable', 'on');
    
    msgbox('Finished loading metabolite map.', 'Action Complete', ...
        'help', 'modal');
else
    msgbox('WARNING: no metabolite map opened!', ...
        'Warning', 'warn', 'modal');
end;


% --- Executes on button press in retrieve_bin_button.
function retrieve_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to retrieve_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

marginWidthProportion = 0.2;
selectedListboxIdx = get(handles.mapped_bins_listbox, 'Value');

if ( isfield(handles, 'storedBins') && ~isempty(handles.storedBins) )
    % Error check, just in case...
    if ( isnumeric(selectedListboxIdx) && ...
            selectedListboxIdx > 0 && ...
            selectedListboxIdx < length(handles.storedBins) + 1 )
        
        % Retrieve the selected metab bin's ID.
        metabBinListboxIdx = get(handles.mapped_bins_listbox, 'Value');
        metabBinListboxAllStrs = ...
            get(handles.mapped_bins_listbox, 'String');
        metabBinListboxStr = metabBinListboxAllStrs{metabBinListboxIdx};
        metabmapBinID = str2num( ...
            regexp(metabBinListboxStr, '^\d+', 'match', 'once') );
        
        set(handles.metabolite_name_popup, 'Value', ...
            handles.storedBins(metabmapBinID).compound_name);
        set(handles.id_source_edit, 'String', ...
            handles.storedBins(metabmapBinID).literature);
        set(handles.proton_id_edit, 'String', ...
            handles.storedBins(metabmapBinID).nmr_isotope);
        set(handles.multiplicity_edit, 'String', ...
            handles.storedBinsMultiplicities{selectedListboxIdx});
        set(handles.hmdb_id_edit, 'String', ...
            handles.storedBinsHmdbIDs(selectedListboxIdx));
        set(handles.peak_count_edit, 'String', ...
            handles.storedBinsPeakNums(selectedListboxIdx));
        chenomxColVal = ...
            handles.storedBinsChenomx{selectedListboxIdx};
        if (chenomxColVal == 'X')
            set(handles.chenomx_checkbox, 'Value', 1.0);
        else
            set(handles.chenomx_checkbox, 'Value', 0.0);
        end;
        
        leftBound = handles.storedBinsLeftBounds(selectedListboxIdx);
        rightBound = handles.storedBinsRightBounds(selectedListboxIdx);
        set(handles.left_bound_edit, 'String', num2str(leftBound, '%.5e'));
        set(handles.right_bound_edit, 'String', ...
            num2str(rightBound, '%.5e'));
        handles.workingLeftBound = leftBound;
        handles.workingRightBound = rightBound;
        
        % Remap the axes and redraw, leaving some wiggle room past the
        % bounds. No check is needed as this button should only be enabled
        % when there is at least one collection loaded.
        boundDiff = abs(leftBound - rightBound)*marginWidthProportion;
        newXLim = [ rightBound - boundDiff   leftBound + boundDiff ];
        set(handles.axes1, 'XLim', newXLim);
        
        guidata(hObject, handles);
        redrawGraph(handles);
    end;
else
    msgbox('Cannot retrieve bin metadata: No binmap loaded.', ...
        'Cannot Complete Request', 'error', 'modal');
end;


% --- Executes on button press in delete_bin_button.
function delete_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedListboxIdx = get(handles.mapped_bins_listbox, 'Value');
% Surpress an "Integer out of range" warning
if (selectedListboxIdx > handles.currentStoredBinCount-1)
    set(handles.mapped_bins_listbox, 'Value', ...
        handles.currentStoredBinCount-1);
end;
% Error check, just in case...
if (isnumeric(selectedListboxIdx) && ...
        isfield(handles, 'currentStoredBinCount') &&...
        selectedListboxIdx > 0 && ...
        selectedListboxIdx < handles.currentStoredBinCount+1)
    handles.storedBinsMetabIDs(selectedListboxIdx)       = [];
    handles.storedBinsMetabolites(selectedListboxIdx)    = [];
    handles.storedBinsLeftBounds(selectedListboxIdx)     = [];
    handles.storedBinsRightBounds(selectedListboxIdx)    = [];
    handles.storedBinsMultiplicities(selectedListboxIdx) = [];
    handles.storedBinsDeconv(selectedListboxIdx)         = [];
    handles.storedBinsProtonIDs(selectedListboxIdx)      = [];
    handles.storedBinsSources(selectedListboxIdx)        = [];
    handles.storedBinsCollectionID(selectedListboxIdx)   = [];
    handles.storedBinsSpectrumID(selectedListboxIdx)     = [];
    handles.storedBinsPeakNums(selectedListboxIdx)       = [];
    handles.storedBinsHmdbIDs(selectedListboxIdx)        = [];
    handles.storedBinsChenomx(selectedListboxIdx)        = [];
    handles.currentStoredBinCount = handles.currentStoredBinCount-1;
end;
if (handles.currentStoredBinCount == 0)
    set(hObject, 'Enable', 'off');
    set(handles.mapped_bins_listbox, 'Value', 1); % Default value for an empty listbox
end;
guidata(hObject, handles);
repopulateMappedBinsList(handles);

% A collection has already been loaded and selected. Redraw graph.
if ( isfield(handles, 'collections') && ...
        ~isempty(handles.collections) && ...
        get(handles.select_collection_popup, 'Value') > 1 )
    redrawGraph(handles);
end;


% --- Executes on button press in save_metabmap_button.
function save_metabmap_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_metabmap_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% -- DCW: TODO: Correctly escape or otherwise handle string fields which
%               contain commas or other delimiting characters.
%targetfile = '';
[filename, pathname] = uiputfile( ...
    {'*.txt;*.csv', 'Tab/comma delimited files (*.txt, *.csv)'; ...
    '*.*', 'All Files (*.*)'} );
if ( ischar(filename) && ischar(pathname) && ...
        ~isempty(filename) && ~isempty(pathname) )
    targetfile = fullfile(pathname,filename);
    %    [fid ~] = fopen(targetfile, 'w');
    %    if ( fid > 0 )
    %        fprintf(fid, ['"Metabolite #","Peak #",Metabolite,"Bin (Lt)",' ...
    %            '"Bin (Rt)",Multiplicity,Deconvolution,"1H Assignment",' ...
    %            '"HMDB No.",Chenomx,Literature,\n']);
    %        for i = 1:handles.currentStoredBinCount
    %            fprintf(fid, '%d,%d,%s,%.8e,%.8e,%s,%s,%s,%d,%s,%s,\n', ...
    %                handles.storedBinsMetabIDs(i), ...
    %                handles.storedBinsPeakNums(i), ...
    %                handles.storedBinsMetabolites{i}, ...
    %                handles.storedBinsLeftBounds(i), ...
    %                handles.storedBinsRightBounds(i), ...
    %                handles.storedBinsMultiplicities{i}, ...
    %                handles.storedBinsDeconv{i}, ...
    %                handles.storedBinsProtonIDs{i}, ...
    %                handles.storedBinsHmdbIDs(i), ...
    %                handles.storedBinsChenomx{i}, ...
    %                handles.storedBinsSources{i});
    %        end;
    %        fclose(fid);
    %    end;
    save_metabmap(targetfile, handles.storedBins);
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
if ( isfield(handles, 'storedBins') )
    % We've got bins loaded already. Append the new bin to the structure.
    %currentStoredBinCount = length(storedBins);
    currentHighBinID = storedBins(length(storedBins)).id;
    nextBinID = currentHighBinID + 1;
    metabPopupIdx = get(handles.metabolite_name_popup, 'Value');
    metabID = handles.metabIDs{metabPopupIdx, 1};
    metabName = handles.metabIDs{metabPopupIdx, 2};
    handles.storedBinsMetabIDs(handles.currentStoredBinCount) = ...
        str2num(metabID);
    handles.storedBinsMetabolites{handles.currentStoredBinCount} = ...
        metabName;
    handles.storedBinsLeftBounds(handles.currentStoredBinCount) = ...
        str2num(get(handles.left_bound_edit, 'String'));
    handles.storedBinsRightBounds(handles.currentStoredBinCount) = ...
        str2num(get(handles.right_bound_edit, 'String'));
    handles.storedBinsMultiplicities{handles.currentStoredBinCount} = ...
        get(handles.multiplicity_edit, 'String');
    handles.storedBinsProtonIDs{handles.currentStoredBinCount} = ...
        get(handles.proton_id_edit, 'String');
    handles.storedBinsSources{handles.currentStoredBinCount} = ...
        get(handles.id_source_edit, 'String');
    handles.storedBinsHmdbIDs(handles.currentStoredBinCount) = ...
        str2num(get(handles.hmdb_id_edit, 'String'));
    handles.storedBinsPeakNums(handles.currentStoredBinCount) = ...
        str2num(get(handles.peak_count_edit, 'String'));
    if (get(handles.chenomx_checkbox, 'Value'))
        handles.storedBinsChenomx{handles.currentStoredBinCount} = 'X';
    else
        handles.storedBinsChenomx{handles.currentStoredBinCount} = ' ';
    end;
    handles.storedBinsCollectionID(handles.currentStoredBinCount) = ...
        0; % -- DCW: For later tracking.
    handles.storedBinsSpectrumID(handles.currentStoredBinCount) = ...
        0; % -- DCW: For later tracking.
else
    % No bins yet exist. Initialize the listbox and the abstract structues
    % with the user-provided values.
    handles.currentStoredBinCount = 1;
    metabPopupIdx = get(handles.metabolite_name_popup, 'Value');
    metabID = handles.metabIDs{metabPopupIdx, 1};
    metabName = handles.metabIDs{metabPopupIdx, 2};
    handles.storedBinsMetabIDs = metabID;
    handles.storedBinsMetabolites = {};
    handles.storedBinsMetabolites{1} = metabName;
    handles.storedBinsLeftBounds = ...
        str2num(get(handles.left_bound_edit, 'String'));
    handles.storedBinsRightBounds = ...
        str2num(get(handles.right_bound_edit, 'String'));
    handles.storedBinsMultiplicities = {};
    handles.storedBinsMultiplicities{1} = ...
        get(handles.multiplicity_edit, 'String');
    handles.storedBinsDeconv = {};
    handles.storedBinsProtonIDs = {};
    handles.storedBinsProtonIDs{1} = ...
        get(handles.proton_id_edit, 'String');
    handles.storedBinsSources = {};
    handles.storedBinsSources{1} = ...
        get(handles.id_source_edit, 'String');
    handles.storedBinsHmdbIDs = ...
        str2num(get(handles.hmdb_id_edit, 'String'));
    handles.storedBinsPeakNums = ...
        str2num(get(handles.peak_count_edit, 'String'));
    handles.storedBinsChenomx = {};
    if (get(handles.chenomx_checkbox, 'Value'))
        handles.storedBinsChenomx{1} = 'X';
    else
        handles.storedBinsChenomx{1} = ' ';
    end;
    handles.storedBinsCollectionID = ...
        0; % -- DCW: For later tracking.
    handles.storedBinsSpectrumID = ...
        0; % -- DCW: For later tracking.
end;
set(handles.delete_bin_button, 'Enable', 'on');
guidata(hObject, handles);
repopulateMappedBinsList(handles);


% --- Executes on selection change in mapped_bins_listbox.
function mapped_bins_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to mapped_bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selectedListboxIdx = get(hObject, 'Value');
% Error check, just in case...
if (isnumeric(selectedListboxIdx) && ...
        isfield(handles, 'storedBins') &&...
        selectedListboxIdx > 0 && ...
        selectedListboxIdx < length(handles.storedBins) + 1)
end;
guidata(hObject, handles);
repopulateMappedBinsList(handles);


% --- Executes on selection change in metabolite_name_popup.
function metabolite_name_popup_Callback(hObject, eventdata, handles)
% hObject    handle to metabolite_name_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metabolite_name_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metabolite_name_popup
itemIdxSelected = get(hObject,'Value');
if (isnumeric(itemIdxSelected) && itemIdxSelected == 2)
    set(handles.new_metab_name_edit, 'Enable', 'on');
else
    set(handles.new_metab_name_edit, 'Enable', 'off');
end;
guidata(hObject, handles);


% -- DCW: Spare callbacks & other hooks

function id_source_edit_Callback(hObject, eventdata, handles)
% hObject    handle to id_source_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of id_source_edit as text
%        str2double(get(hObject,'String')) returns contents of id_source_edit as a double


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


% --- Executes on button press in chenomx_checkbox.
function chenomx_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to chenomx_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of chenomx_checkbox


function hmdb_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to hmdb_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of hmdb_id_edit as text
%        str2double(get(hObject,'String')) returns contents of hmdb_id_edit as a double


function new_metab_name_edit_Callback(hObject, eventdata, handles)
% hObject    handle to new_metab_name_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of new_metab_name_edit as text
%        str2double(get(hObject,'String')) returns contents of new_metab_name_edit as a double


% --- Executes when selected object is changed in set_bound_mode_uipanel.
function set_bound_mode_uipanel_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in set_bound_mode_uipanel
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


function peak_count_edit_Callback(hObject, eventdata, handles)
% hObject    handle to peak_count_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of peak_count_edit as text
%        str2double(get(hObject,'String')) returns contents of peak_count_edit as a double


function selected_display_spectra_edit_Callback(hObject, eventdata, handles)
% hObject    handle to selected_display_spectra_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selected_display_spectra_edit as text
%        str2double(get(hObject,'String')) returns contents of selected_display_spectra_edit as a double
