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

% Last Modified by GUIDE v2.5 08-Dec-2011 17:31:24

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


% --- Set the Metabolite name popup menu to its initial state.
function initializeMetabIDNameTable(hObject, handles)
% hObject         handle to select_collection_popup (see GCBO)
% handles         structure with handles and user data (see GUIDATA)
handles.metaboliteIDNameTable = { ...
    -3 '' '0'; ...
    -2 '* Add a new metabolite... *' '0'; ...
    -1 '** Add a new unknown... **' '1'};
guidata(hObject, handles);


% --- Add a new metabolite to the list of known and unknown compounds.
% *** NB: *** This method of updating the handles structure does not
%             work as written. It is included -- and the hooks to
%             facilitate its logic -- for reference should we find a way to
%             correctly update the handles struct in a subroutine.
function newMetabIdx = appendNewMetaboliteToIDNameTable(hObject, ...
    handles, newMetabName, unknownMetab)
% hObject         handle to select_collection_popup (see GCBO)
% handles         structure with handles and user data (see GUIDATA)
% newMetabName    the name of the new metabolite to create
% PRE: Nonempty string
% unknownMetab    Boolean flag should be true for UNKNOWN metabolites
% PRE: boolean or numeric 0 or 1
% newMetabIdx     Return value; contains new metab's index in the table.

% We should never fail this check.
if ( isfield(handles, 'metaboliteIDNameTable') )
    % Precondition error checks.
    if ( ischar(newMetabName) && ~isempty(newMetabName) && ...
            (islogical(unknownMetab) || (isnumeric(unknownMetab) && ...
            (unknownMetab == 0 || unknownMetab == 1))))
        mIDNTColumnIDs = [ handles.metaboliteIDNameTable{:,1} ];
        newMetabID = max(mIDNTColumnIDs) + 1;
        newMetabIdx = length(mIDNTColumnIDs) + 1;
        if ( newMetabID <= 0 )
            newMetabID = 1;
        end;
        handles.metaboliteIDNameTable = ...
            [ handles.metaboliteIDNameTable ;
            {newMetabID} ...
            newMetabName ...
            num2str(unknownMetab) ];
        guidata(hObject, handles);
    else
        msgbox('ERROR: Bad metabolite name or bad known metabolite flag!');
    end;
else
    msgbox(['ERROR: Metabolite name drop-down was not correctly ' ...
        'initialized!']);
end;


% --- Fill the Metabolite Name popup menu on the GUI
function repopulateMetabPopupMenu(handles)
% hObject    handle to select_collection_popup (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
set(handles.metabolite_name_popup, 'String', ...
    handles.metaboliteIDNameTable(:,2));


% --- Draws all stored bins, the working bin, and the currently selected
%     spectrum (or all spectra if the mode is Overlay).
function redrawGraph(handles)
% handles    structure with handles and user data (see GUIDATA)
popupCollectionNum = get(handles.select_collection_popup, 'Value') - 1; % Popup entries are 1-indexed.
popupSpectrumNum = get(handles.select_spectrum_popup, 'Value');

clearGraph(handles);

axes(handles.axes1);
hold on;
if ( isfield(handles, 'collections') && ~isempty(handles.collections)...
        && popupCollectionNum > 0 )
    % At least one collection has been loaded & selected. Proceed.
    
    if ( get(handles.individual_mode_radiobutton, 'Value') == ...
            get(handles.individual_mode_radiobutton, 'Max') )
        
        % We are in individual spectrum display mode.
        % Draw the selected spectrum.
        plot(handles.collections{popupCollectionNum}.x, ...
            handles.collections{popupCollectionNum}.Y(:,popupSpectrumNum));
        
    end;
    
    if ( get(handles.overlaid_mode_radiobutton, 'Value') == ...
            get(handles.overlaid_mode_radiobutton, 'Max') )
        
        % We are in overlay mode. Populate the graph with all spectra
        % overlaid.
        plot(handles.collections{popupCollectionNum}.x, ...
            handles.collections{popupCollectionNum}.Y);
    end;
    
    if ( get(handles.selected_mode_radiobutton, 'Value') == ...
            get(handles.selected_mode_radiobutton, 'Max') )
        
        % We are in selective display mode. Populate the graph with only
        % the selected spectra overlaid.
        userSelectedSpectraStr = ...
            get(handles.selected_display_spectra_edit, 'String');
        userSelectedSpectraIDs = ...
            regexp(userSelectedSpectraStr, '(\d+)', 'tokens');
        userSelectedSpectraIDs = ...
            [ userSelectedSpectraIDs{:} ]; % Flatten
        userSelectedSpectraRanges = ...
            regexp(userSelectedSpectraStr, '(\d+)-(\d+)', 'tokens');
        userSelectedSpectraRanges = ...
            [ userSelectedSpectraRanges{:} ]; % Flatten
        
        % Lose the IDs which are part of range bounds.
        if (~isempty(userSelectedSpectraRanges))
            userSelectedSpectraIDIdxs = ...
                find(~ismember(userSelectedSpectraIDs, ...
                userSelectedSpectraRanges(:)));
            userSelectedSpectraIDs = ...
                userSelectedSpectraIDs(userSelectedSpectraIDIdxs(:));
        end;
        
        % Append the individual spectra IDs to the list.
        for i=1:length(userSelectedSpectraRanges)/2
            startID = ...
                str2double(userSelectedSpectraRanges(1+2*(i-1)));
            endID = str2double(userSelectedSpectraRanges(2+2*(i-1)));
            for j=startID:endID
                userSelectedSpectraIDs = ...
                    [ userSelectedSpectraIDs num2str(j) ];
            end;
        end;
        
        % Convert to scalar numbers.
        userSingleSpectraIDCount = length(userSelectedSpectraIDs);
        userSelectedSpectraIDsNumVal = ...
            zeros(userSingleSpectraIDCount, 1);
        for i=1:userSingleSpectraIDCount
            userSelectedSpectraIDsNumVal(i) = ...
                str2double(userSelectedSpectraIDs(i));
        end;
        userSelectedSpectraIDsNumVal = ...
            sort(userSelectedSpectraIDsNumVal);
        
        % Make sure all the possible spectrum IDs are in-bounds.
        if ( isempty(find(userSelectedSpectraIDsNumVal > ...
                size(handles.collections{popupCollectionNum}.Y, 2), 1)) )
            
            % Plot JUST the matching spectra.
            plot(handles.collections{popupCollectionNum}.x, ...
                handles.collections{popupCollectionNum}.Y(:,userSelectedSpectraIDsNumVal(:)));
            
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

% Draw all stored bin bounds not marked as deleted.
if ( isfield(handles, 'storedBins') )
    for i = 1:length(handles.storedBins)
        if ( ~handles.storedBins(i).was_deleted )
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
end;
hold off;


% --- Fill the Mapped Bins listbox on the GUI
function repopulateMappedBinsList(handles)
% handles    structure with handles and user data (see GUIDATA)
targetListboxIdx = get(handles.mapped_bins_listbox, 'Value');
if ( isfield(handles, 'storedBins') )
    storedBinsArrayLen = length(handles.storedBins);
    stringPropCell = cell(storedBinsArrayLen, 1);
    for i=1:storedBinsArrayLen
        stringPropCell{i} = [ ...
            num2str(handles.storedBins(i).id, '%d') ',' ...
            handles.storedBins(i).compound_name ',' ...
            num2str(handles.storedBins(i).bin.left, '%.3f') ',' ...
            num2str(handles.storedBins(i).bin.right, '%.3f') ];
    end;
end;
set(handles.mapped_bins_listbox, 'String', stringPropCell);
if ( targetListboxIdx < 1 ||  targetListboxIdx > storedBinsArrayLen )
    set(handles.mapped_bins_listbox, 'Value', 1);
else
    set(handles.mapped_bins_listbox, 'Value', targetListboxIdx);
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
initializeMetabIDNameTable(hObject, handles);


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


% --- Executes during object creation, after setting all properties.
function j_values_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to j_values_edit (see GCBO)
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
set(handles.no_bound_mode_radiobutton,'Value', ...
    get(handles.no_bound_mode_radiobutton,'Max'));
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
    set(handles.no_bound_mode_radiobutton, 'Enable', 'on');
else
    set(handles.select_collection_popup, 'Value', 1);
    set(handles.select_collection_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_collection_popup,'Enable','off');
    set(handles.select_spectrum_popup, 'Value', 1);
    set(handles.select_spectrum_popup,'String','[ NO COLLECTION LOADED ]');
    set(handles.select_spectrum_popup,'Enable','off');
    set(handles.left_bound_mode_radiobutton,'Enable','off');
    set(handles.right_bound_mode_radiobutton,'Enable','off');
    set(handles.no_bound_mode_radiobutton, 'Enable', 'off');
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

if ( popupCollectionNum > 0 )
    % A collection is selected.
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
            set(handles.select_spectrum_popup, 'Enable', 'on');
            set(handles.append_bin_button, 'Enable', 'on');
            set(handles.retrieve_bin_button, 'Enable', 'on');
            redrawGraph(handles);
            
        case 'selected_mode_radiobutton'
            % We intend to display a reduced set of overlaid spectra.
            % Allow bin appending but disable the spectrum select popup.
            set(handles.select_spectrum_popup, 'Enable', 'off');
            set(handles.append_bin_button, 'Enable', 'on');
            set(handles.retrieve_bin_button, 'Enable', 'on');
            if ( ~isempty( ...
                    get(handles.selected_display_spectra_edit, ...
                    'String') ) )
                redrawGraph(handles);
            end;
            
        otherwise
            % Make sure the individual mode is selected.
            set(eventdata.NewValue,'Tag','individual_mode_radiobutton');
    end;
else
    % No collection is actually selected to display.
    set(handles.select_spectrum_popup, 'Enable', 'off');
    set(handles.append_bin_button, 'Enable', 'off');
    set(handles.retrieve_bin_button, 'Enable', 'off');
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
    
    handles.storedBins = load_metabmap(fullfile(pathname, filename), ...
        'no_deleted_bins');
    
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
            num2str(handles.storedBins(i).compound_id) '<#%$>' ...
            num2str(~handles.storedBins(i).is_known_compound) ];
    end;
    tempIDNameTable = unique(tempIDNameTable);
    tempIDNameTable = ...
        regexp(unique(tempIDNameTable), ...
        '^(.+)<%\$#>(\d+)<#%\$>(\d)$', 'tokens', 'once');
    initializeMetabIDNameTable(hObject, handles);
    for i=1:length(tempIDNameTable)
        handles.metaboliteIDNameTable = ...
            [ handles.metaboliteIDNameTable ; ...
            {str2double(tempIDNameTable{i}{2})} ...
            tempIDNameTable{i}{1} ...
            tempIDNameTable{i}{3}];
    end;
    guidata(hObject, handles);
    repopulateMetabPopupMenu(handles);
    
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
    msgbox('WARNING: No metabolite map opened!', ...
        'Warning', 'warn', 'modal');
end;


% --- Executes on button press in retrieve_bin_button.
function retrieve_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to retrieve_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

marginWidthProportion = 0.2;

% Retrieve the selected metab bin's index position in the list.
metabBinListboxIdx = get(handles.mapped_bins_listbox, 'Value');

if ( isfield(handles, 'storedBins') && ~isempty(handles.storedBins) )
    % Error check, just in case...
    if ( isnumeric(metabBinListboxIdx) && ...
            metabBinListboxIdx > 0 && ...
            metabBinListboxIdx < length(handles.storedBins) + 1 )
        
        % Parse the bin's primary ID and map it back to its index
        % in the actual cell array of CompoundBin objects.
        metabBinListboxAllStrs = ...
            get(handles.mapped_bins_listbox, 'String');
        metabBinListboxStr = metabBinListboxAllStrs{metabBinListboxIdx};
        metabmapBinID = str2double( ...
            regexp(metabBinListboxStr, '^\d+', 'match', 'once') );
        metabmapCellArrIdx = ...
            find(ismember( [handles.storedBins(:).id], metabmapBinID ));
        
        % Get the correct index for the metabolite name popup.
        metabIDNameTblLen = length(handles.metaboliteIDNameTable(:,1));
        tempIDStrArr = cell(metabIDNameTblLen, 1);
        for i=1:metabIDNameTblLen
            tempIDStrArr{i} = num2str(handles.metaboliteIDNameTable{i,1});
        end;
        metabPopupIdx = find( ismember(tempIDStrArr, ...
            num2str(handles.storedBins(metabmapCellArrIdx).compound_id)) );
        set(handles.metabolite_name_popup, 'Value', metabPopupIdx);
        
        % Populate remaining fields.
        set(handles.unknown_metab_checkbox, 'Value', ...
            ~handles.storedBins(metabmapCellArrIdx).is_known_compound );
        set(handles.chenomx_checkbox, 'Value', ...
            handles.storedBins(metabmapCellArrIdx).chenomix_was_used );
        hmdbID = handles.storedBins(metabmapCellArrIdx).hmdb_id;
        if ( isnan(hmdbID) )
            hmdbIDStr = '';
        else
            hmdbIDStr = num2str(hmdbID);
        end;
        set(handles.hmdb_id_edit, 'String', hmdbIDStr);
        set(handles.multiplicity_edit, 'String', ...
            handles.storedBins(metabmapCellArrIdx).multiplicity);
        peakCount = handles.storedBins(metabmapCellArrIdx).num_peaks;
        if ( isnan(peakCount) )
            peakCountStr = '';
        else
            peakCountStr = num2str(peakCount);
        end;
        set(handles.peak_count_edit, 'String', peakCountStr);
        jValueArr = handles.storedBins(metabmapCellArrIdx).j_values;
        jValuesCSV = '';
        for i=1:length(jValueArr)
            jValuesCSV = [ jValuesCSV num2str(jValueArr(i)) ',' ];
        end;
        jValuesCSV = jValuesCSV(1:length(jValuesCSV) - 1);
        set(handles.j_values_edit, 'String', jValuesCSV);
        set(handles.proton_id_edit, 'String', ...
            handles.storedBins(metabmapCellArrIdx).nucleus_assignment);
        set(handles.id_source_edit, 'String', ...
            handles.storedBins(metabmapCellArrIdx).literature);
        set(handles.nmr_isotope_edit, 'String', ...
            handles.storedBins(metabmapCellArrIdx).nmr_isotope);
        
        % Handle logic for populating the bin bounds' edit boxes and
        % highlighting the boundaries on the graph.
        leftBound = handles.storedBins(metabmapCellArrIdx).bin.left;
        rightBound = handles.storedBins(metabmapCellArrIdx).bin.right;
        set(handles.left_bound_edit, 'String', ...
            num2str(leftBound, '%.7e'));
        set(handles.right_bound_edit, 'String', ...
            num2str(rightBound, '%.7e'));
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
    msgbox([ 'Cannot retrieve metabolite segment metadata: ' ...
        'no MetabMap loaded.' ], ...
        'Cannot Complete Request', 'error', 'modal');
end;


% --- Executes on button press in delete_bin_button.
function delete_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
deleteAffirm = 'Yes, delete';
deleteDeny = 'No, keep';
userChoice = questdlg([ 'Are you sure you want to delete ' ...
    'the selected metabolite segment?' ], ...
    'Confirm Delete', deleteAffirm, deleteDeny, deleteDeny);
if ( strcmp(userChoice, deleteAffirm) )
    % User has confirmed the choice to delete.
    selectedListboxIdx = get(handles.mapped_bins_listbox, 'Value');
    displayedBinCount = length(get(handles.mapped_bins_listbox, 'String'));
    % Error check, just in case...
    if (isnumeric(selectedListboxIdx) && selectedListboxIdx > 0 && ...
            selectedListboxIdx <= displayedBinCount)
        
        % Retrieve the selected metab bin's index position in the list.
        metabBinListboxIdx = get(handles.mapped_bins_listbox, 'Value');
        
        % Parse the bin's primary ID and map it back to its index
        % in the actual cell array of CompoundBin objects.
        metabBinListboxAllStrs = ...
            get(handles.mapped_bins_listbox, 'String');
        metabBinListboxStr = metabBinListboxAllStrs{metabBinListboxIdx};
        metabmapBinID = str2double( ...
            regexp(metabBinListboxStr, '^\d+', 'match', 'once') );
        metabmapCellArrIdx = ...
            find(ismember([handles.storedBins(:).id], metabmapBinID), 1);
        
        % Mark the bin as deleted.
        %handles.storedBins(metabmapCellArrIdx).was_deleted = true;
        tempCB = handles.storedBins(metabmapCellArrIdx);
        handles.storedBins(metabmapCellArrIdx) = [];
        handles.storedBins = [ handles.storedBins ...
            CompoundBin(CompoundBin.csv_file_header_string(), ...
            regexprep(tempCB.as_csv_string, '^(\d+),"",', '$1,"X",', 'once')) ];
        
    end;
    if (displayedBinCount == 1)
        % We've just marked our only metab bin as "deleted." Disable
        % the delete button.
        set(hObject, 'Enable', 'off');
    end;
    guidata(hObject, handles);
    repopulateMappedBinsList(handles);
    
    % A collection has already been loaded and selected. Redraw graph.
    if ( isfield(handles, 'collections') && ...
            ~isempty(handles.collections) && ...
            get(handles.select_collection_popup, 'Value') > 1 )
        redrawGraph(handles);
    end;
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
    rightRadioButton = get(handles.right_bound_mode_radiobutton, 'Value');
    leftRadioButton = get(handles.left_bound_mode_radiobutton, 'Value');
    noneRadioButton = get(handles.no_bound_mode_radiobutton, 'Value');
    if ( rightRadioButton == ...
            get(handles.right_bound_mode_radiobutton, 'Max') )
        % User has selected right x bound.
        handles.workingRightBound = clickXCoord;
        set(handles.right_bound_edit, 'String', num2str(clickXCoord,'%.7e'));
    end;
    if ( leftRadioButton == ...
            get(handles.left_bound_mode_radiobutton, 'Max') )
        % User has selected left x bound.
        handles.workingLeftBound = clickXCoord;
        set(handles.left_bound_edit, 'String', num2str(clickXCoord,'%.7e'));
    end;
    if ( noneRadioButton == ...
            get(handles.no_bound_mode_radiobutton, 'Max') )
        % User has not selected any working bounds.
    end;
    guidata(hObject, handles);
    redrawGraph(handles);
    
end;


function left_bound_edit_Callback(hObject, eventdata, handles)
% hObject    handle to left_bound_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[userLeftBound convResult] = str2num(get(hObject,'String'));
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
[userRightBound convResult] = str2num(get(hObject,'String'));
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
metabPopupIdx = get(handles.metabolite_name_popup, 'Value');
metabSelectionApproved = ( metabPopupIdx > 3 );
newMetabNameFieldStr = get(handles.new_metab_name_edit, 'String');
if ( metabPopupIdx > 1 )
    if ( metabPopupIdx == 2 )
        
        % User is attempting to add a new metabolite to the table.
        if ( ~isempty(newMetabNameFieldStr) )
            set(handles.unknown_metab_checkbox, 'Value', 0);
            
            % We should never fail this check.
            if ( isfield(handles, 'metaboliteIDNameTable') )
                % Precondition error checks.
                if ( ischar(newMetabNameFieldStr) && ...
                        ~isempty(newMetabNameFieldStr))
                    mIDNTColumnIDs = [ handles.metaboliteIDNameTable{:,1} ];
                    newMetabID = max(mIDNTColumnIDs) + 1;
                    newMetabIdx = length(mIDNTColumnIDs) + 1;
                    if ( newMetabID <= 0 )
                        newMetabID = 1;
                    end;
                    handles.metaboliteIDNameTable = ...
                        [ handles.metaboliteIDNameTable ;
                        {newMetabID} ...
                        newMetabNameFieldStr ...
                        num2str(get(handles.unknown_metab_checkbox, ...
                        'Value')) ];
                    guidata(hObject, handles);
                else
                    msgbox([ 'ERROR: Bad metabolite name or bad ' ...
                        'known metabolite flag!' ]);
                end;
            else
                msgbox([ 'ERROR: Metabolite name drop-down was not ' ...
                    'correctly initialized!' ]);
            end;
            %newMetabPopupMenuIdx = ...
            %    appendNewMetaboliteToIDNameTable( ...
            %    hObject, handles, newMetabNameFieldStr, 0);
            repopulateMetabPopupMenu(handles);
            %set(handles.metabolite_name_popup, ...
            %    'Value', newMetabPopupMenuIdx);
            set(handles.metabolite_name_popup, ...
                'Value', newMetabIdx);
            metabSelectionApproved = true;
        end;
    end;
    if ( metabPopupIdx == 3 )
        % User is attempting to add a new and UNKNOWN metabolite
        % to the table.
        if ( isempty(newMetabNameFieldStr) )
            leftBound = ...
                str2double(get(handles.left_bound_edit, 'String'));
            rightBound = ...
                str2double(get(handles.right_bound_edit, 'String'));
            newMetabNameFieldStr = ...
                [ 'U' num2str((leftBound+rightBound)/2, '%.3f') ];
            set(handles.new_metab_name_edit, 'String', ...
                newMetabNameFieldStr);
        end;
        set(handles.unknown_metab_checkbox, 'Value', 1);
        
        % We should never fail this check.
        if ( isfield(handles, 'metaboliteIDNameTable') )
            % Precondition error checks.
            if ( ischar(newMetabNameFieldStr) && ...
                    ~isempty(newMetabNameFieldStr))
                mIDNTColumnIDs = [ handles.metaboliteIDNameTable{:,1} ];
                newMetabID = max(mIDNTColumnIDs) + 1;
                newMetabIdx = length(mIDNTColumnIDs) + 1;
                if ( newMetabID <= 0 )
                    newMetabID = 1;
                end;
                handles.metaboliteIDNameTable = ...
                    [ handles.metaboliteIDNameTable ;
                    {newMetabID} ...
                    newMetabNameFieldStr ...
                    num2str(get(handles.unknown_metab_checkbox, ...
                    'Value')) ];
                guidata(hObject, handles);
            else
                msgbox([ 'ERROR: Bad metabolite name or bad ' ...
                    'known metabolite flag!' ]);
            end;
        else
            msgbox([ 'ERROR: Metabolite name drop-down was not ' ...
                'correctly initialized!' ]);
        end;
        %newMetabPopupMenuIdx = ...
        %    appendNewMetaboliteToIDNameTable( ...
        %    hObject, handles, newMetabNameFieldStr, 1);
        repopulateMetabPopupMenu(handles);
        %set(handles.metabolite_name_popup, 'Value', newMetabPopupMenuIdx);
        set(handles.metabolite_name_popup, 'Value', newMetabIdx);
        metabSelectionApproved = true;
    end;
    if ( metabSelectionApproved )
        set(handles.new_metab_name_edit, 'String', '');
        set(handles.new_metab_name_edit, 'Enable', 'off');
        % If a new metabolite was added, our popup menu selection may
        % have automatically changed.
        metabPopupIdx = get(handles.metabolite_name_popup, 'Value');
        compound_id = ...
            handles.metaboliteIDNameTable{metabPopupIdx, 1};
        compound_name = ...
            handles.metaboliteIDNameTable{metabPopupIdx, 2};
        hmdb_id = get(handles.hmdb_id_edit, 'String');
        userMultStr = get(handles.multiplicity_edit, 'String');
        num_peaks = str2double(get(handles.peak_count_edit, 'String'));
        j_values = get(handles.j_values_edit, 'String');
        nucleus_assignment = get(handles.proton_id_edit, 'String');
        leftBound = str2double(get(handles.left_bound_edit, 'String'));
        rightBound = str2double(get(handles.right_bound_edit, 'String'));
        nmrIso = get(handles.nmr_isotope_edit, 'String');
        if ( get(handles.unknown_metab_checkbox, 'Value') == 0 )
            is_known_compound = 'X';
        else
            is_known_compound = '';
        end;
        if ( get(handles.chenomx_checkbox, 'Value') )
            chenomix_was_used = 'X';
        else
            chenomix_was_used = '';
        end;
        literature = get(handles.id_source_edit, 'String');
        
        storedBinsExist = isfield(handles, 'storedBins');
        if ( storedBinsExist )
            bin_id = max([ handles.storedBins(:).id ]) + 1;
        else
            bin_id = 1;
        end;
        errmsg = 0;
        try
            header_string = CompoundBin.csv_file_header_string();
            % "Bin ID",
            % "Deleted"
            % "Compound ID"
            % "Compound Name"
            % "Known Compound"
            % "Bin (Lt)"
            % "Bin (Rt)"
            % "Multiplicity"
            % "Peaks to Select"
            % "J (Hz)"
            % "Nucleus Assignment"
            % "HMDB ID"
            % "Sample-types that may contain compound"
            % "Chenomx"
            % "Literature"
            % "NMR Isotope"
            % "Notes"
            newBin = CompoundBin(header_string, ...
                sprintf([ ...
                '%d,,%d,"%s",' ...
                '"%s",%g,%g,'  ...
                '"%s",%d,"%s",' ...
                '"%s",%s,""' ...
                '"%s","%s","%s",""' ], ...
                bin_id, compound_id, compound_name,...
                is_known_compound, leftBound, rightBound, ...
                userMultStr, num_peaks, j_values, ...
                nucleus_assignment, hmdb_id, ...
                chenomix_was_used, literature, nmrIso));
        catch E
            errmsg = E.message;
        end
        if ( ischar(errmsg) )
            msgbox([ 'Could not create new metabolite segment: ' ...
                errmsg ], 'Error', 'Error');
        else
            if ( storedBinsExist )
                % We've got bins loaded already. Append the new bin
                % to the structure.
                nextBinIdx = length(handles.storedBins) + 1;
                handles.storedBins(nextBinIdx) = newBin;
                % -- DCW: For later tracking.
                %handles.storedBinsCollectionID(...
                %handles.currentStoredBinCount) = 0;
                % -- DCW: For later tracking.
                %handles.storedBinsSpectrumID(...
                %handles.currentStoredBinCount) = 0;
            else
                % No bins yet exist. Initialize the listbox and the
                % abstract structures with the user-provided values.
                handles.storedBins = newBin;
                % -- DCW: For later tracking.
                %handles.storedBinsCollectionID = 0;
                % -- DCW: For later tracking.
                %handles.storedBinsSpectrumID = 0;
            end;
            set(handles.delete_bin_button, 'Enable', 'on');
            guidata(hObject, handles);
            repopulateMappedBinsList(handles);
        end;
    else
        msgbox('ERROR: Invalid Metabolite Name selection.');
    end;
else
    msgbox('ERROR: Invalid Metabolite Name selection.');
end;


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
if ( itemIdxSelected == 2 || itemIdxSelected == 3 )
    set(handles.new_metab_name_edit, 'Enable', 'on');
else
    set(handles.new_metab_name_edit, 'Enable', 'off');
end;
if ( itemIdxSelected == 3 )
    set(handles.unknown_metab_checkbox, 'Enable', 'on');
end;
set(handles.unknown_metab_checkbox, 'Value', ...
    (str2double(handles.metaboliteIDNameTable(itemIdxSelected,3)) == 1));
guidata(hObject, handles);


% --- Executes on button press in unknown_metab_checkbox.
function unknown_metab_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to unknown_metab_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of unknown_metab_checkbox
if ( get(hObject,'Value') && ...
        get(handles.metabolite_name_popup,'Value') == 2 )
    set(handles.metabolite_name_popup,'Value', 3);
end;
if ( ~get(hObject,'Value') && ...
        get(handles.metabolite_name_popup,'Value') == 3 )
    set(handles.metabolite_name_popup,'Value', 2);
end;


function selected_display_spectra_edit_Callback(hObject, eventdata, handles)
% hObject    handle to selected_display_spectra_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of selected_display_spectra_edit as text
%        str2double(get(hObject,'String')) returns contents of selected_display_spectra_edit as a double
if ( get(handles.selected_mode_radiobutton, 'Value') == ...
        get(handles.selected_mode_radiobutton, 'Max'))
    redrawGraph(handles)
end;


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

if ( strcmp(eventdata.Key, 'backspace') || ...
        strcmp(eventdata.Key, 'delete') )
    if ( strcmp(get(handles.delete_bin_button, 'Enable'), 'on') )
        delete_bin_button_Callback(hObject, eventdata, handles);
    end;
end;

%if ( isfield(eventdata, 'Modifier') && ...
%        ~isempty(eventdata.Modifier) && ...
%        strcmp(eventdata.Modifier{1}, 'alt') )
if ( isfield(eventdata, 'Modifier') && ...
        ~isempty(eventdata.Modifier) && ...
        strcmp(eventdata.Modifier{1}, 'control') )
    switch eventdata.Key
        case 'a'
            if ( strcmp(get(handles.append_bin_button, 'Enable'), 'on') )
                append_bin_button_Callback( ...
                    hObject, eventdata, handles);
            end;
        case 'f'
            if ( strcmp(get(handles.retrieve_bin_button, 'Enable'), 'on') )
                retrieve_bin_button_Callback( ...
                    hObject, eventdata, handles);
            end;
        case 'l'
            load_metabmap_button_Callback(hObject, eventdata, handles);
        case 'o'
            load_collection_button_Callback(hObject, eventdata, handles);
        case 's'
            save_metabmap_button_Callback(hObject, eventdata, handles);
    end;
end;


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if ( isfield(handles, 'storedBins') && ...
        ~isempty(handles.storedBins) )
    switch questdlg('Save metabolite map before closing?')
        case 'Yes'
            save_metabmap_button_Callback(hObject, eventdata, handles);
            delete(hObject);
        case 'No'
            secondResponse = ...
                questdlg('All changes will be lost! Are you sure?');
            if ( strcmp(secondResponse, 'Yes') )
                delete(hObject);
            end;
        otherwise
            % Do nothing and return to the figure.
    end;
else
    delete(hObject);
end;



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


function j_values_edit_Callback(hObject, eventdata, handles)
% hObject    handle to j_values_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of j_values_edit as text
%        str2double(get(hObject,'String')) returns contents of j_values_edit as a double


function nmr_isotope_edit_Callback(hObject, eventdata, handles)
% hObject    handle to nmr_isotope_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nmr_isotope_edit as text
%        str2double(get(hObject,'String')) returns contents of nmr_isotope_edit as a double


% --- Executes during object creation, after setting all properties.
function nmr_isotope_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nmr_isotope_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
