function varargout = select_bin_subset(varargin)
% SELECT_BIN_SUBSET MATLAB code for select_bin_subset.fig
%      SELECT_BIN_SUBSET, by itself, creates a new SELECT_BIN_SUBSET or raises the existing
%      singleton*.
%
%      H = SELECT_BIN_SUBSET returns the handle to a new SELECT_BIN_SUBSET or the handle to
%      the existing singleton*.
%
%      SELECT_BIN_SUBSET('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SELECT_BIN_SUBSET.M with the given input arguments.
%
%      SELECT_BIN_SUBSET('Property','Value',...) creates a new SELECT_BIN_SUBSET or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before select_bin_subset_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to select_bin_subset_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help select_bin_subset

% Last Modified by GUIDE v2.5 01-Aug-2011 21:31:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @select_bin_subset_OpeningFcn, ...
    'gui_OutputFcn',  @select_bin_subset_OutputFcn, ...
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


% --- Executes just before select_bin_subset is made visible.
function select_bin_subset_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to select_bin_subset (see VARARGIN)

% Choose default command line output for select_bin_subset
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes select_bin_subset wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Initialize the environment.
app_init(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = select_bin_subset_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function max_error_match_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_error_match_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Initialize environment
function app_init(hObject, handles)
% hObject    handle to load_loadings_button (see GCBO)
% handles    structure with handles and user data (see GUIDATA)
set(handles.binlist_uitable, 'Data', {}); % Clear the table initially.
handles.sortMode = 1;
if ( isfield(handles, 'binListCount') )
    handles = rmfield(handles, 'binListCount');
end;
if ( isfield(handles, 'binLoadingsCount') )
    handles = rmfield(handles, 'binLoadingsCount');
end;
guidata(hObject, handles);


% --- Executes on button press in load_binlist_button.
function load_binlist_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_binlist_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
overriddenEOR = ' ,;\t\n';
[filename pathname] = uigetfile( ...
    {'*.txt','Comma and Semicolon Delimited Binlist (*.txt)'; ...
    '*.*','All Files (.*.*)'}, ...
    'Select bin list file...','bins.txt');
if ( ischar(filename) )
    fullpath = [pathname filename];
    fid = fopen(fullpath, 'r');
    if ( fid > 2 )
        
        binBounds = textscan(fid, '%f %f', 'Delimiter', overriddenEOR);
        fclose(fid);
        handles.binListCount = length(binBounds{1});
        guidata(hObject,handles);
        
        % Need the data to be stored in a cell of cells.
        vectorOfOnes = ones(1, handles.binListCount);
        binBounds = [ ...
            mat2cell(binBounds{1}, vectorOfOnes, 1) ...
            mat2cell(binBounds{2}, vectorOfOnes, 1) ];
        
        if ( isfield(handles, 'binLoadingsCount') && ...
                handles.binLoadingsCount ~= handles.binListCount )
            msgbox(['Mismatched record counts!' 10 13 10 13 ...
                'Bin list record count: ' ...
                num2str(handles.binListCount) 10 13 ...
                'Bin loadings record count: ' ...
                num2str(handles.binLoadingsCount) ], ...
                'Unmatched file record counts','error','modal');
        else
            dataOnTable = get(handles.binlist_uitable, 'Data');
            cellsOfLogical = mat2cell( ...
                false(handles.binListCount, 1), ...
                vectorOfOnes, 1);
            cellsOfNaN = mat2cell( ...
                NaN(handles.binListCount, 1), ...
                vectorOfOnes, 1);
            if ( isempty(dataOnTable) )
                binBounds = [ cellsOfLogical cellsOfNaN binBounds ...
                    cellsOfNaN cellsOfLogical ];
            else
                binBounds = [ dataOnTable(:, 1) dataOnTable(:, 2) ...
                    binBounds dataOnTable(:, 5) dataOnTable(:, 6) ];
            end;
            set(handles.binlist_uitable, 'Data', binBounds);
        end;
    else
        msgbox(['Unable to open bin list file ' fullpath '!'], ...
            'Could not open file', 'error', 'modal');
    end;
end;


% --- Executes on button press in load_loadings_button.
function load_loadings_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_loadings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile( ...
    {'*.csv;*.txt','Tab/Comma Delimited file (*.csv, *.txt)'; ...
    '*.*','All Files (*.*)'}, ...
    'Select bin OPLS loadings CSV file...','binloadings.csv');
if ( ischar(filename) )
    fullpath = [pathname filename];
    fid = fopen(fullpath, 'r');
    if ( fid > 2 )
        binLoadings = textscan(fid, '%f %f %f %d', ...
            'Delimiter', ' ,\t', 'HeaderLines', 1);
        fclose(fid);
        handles.binLoadingsCount = length(binLoadings{1});
        guidata(hObject,handles);
        
        % Need the data to be stored in a cell of cells.
        vectorOfOnes = ones(1, handles.binLoadingsCount);
        binLoadings = [ ...
            mat2cell(binLoadings{1}, vectorOfOnes, 1) ...
            mat2cell(binLoadings{2}, vectorOfOnes, 1) ...
            mat2cell(binLoadings{3}, vectorOfOnes, 1) ...
            mat2cell(logical(binLoadings{4}), vectorOfOnes, 1) ];
        
        dataOnTable = get(handles.binlist_uitable, 'Data');
        matchingErrorString = '';
        if ( isempty(dataOnTable) || isnan(dataOnTable{1,3}) )
            % Either the table is blank or only an OPLS loadings file has
            % been loaded. Replace existing table data.
            cellsOfNaN = mat2cell( ...
                nan(handles.binLoadingsCount, 1), vectorOfOnes, 1 );
            dataOnTable = [      ...
                binLoadings(:,4) ... % Default "Include?".
                binLoadings(:,1) ... % Bin center.
                cellsOfNaN       ... % Indicating no bin bounds
                cellsOfNaN       ... %     have been loaded.
                binLoadings(:,2) ... % P score.
                binLoadings(:,4) ... % Significance.
                ];
        else
            % Fetch user's match threshold (given in radial ppm).
            max_error_match = ...
                str2double(get(handles.max_error_match_edit,'String'));
            recordsOnTableCount = length(dataOnTable);
            sourceBinBoundsMatched = false(recordsOnTableCount, 1);
            for i = 1:handles.binLoadingsCount
                concentration = binLoadings{i,1};
                pScore = binLoadings{i,2};
                isSignificant = binLoadings{i,4};
                matched = false;
                for j = 1:recordsOnTableCount
                    left = dataOnTable{j,3};
                    right = dataOnTable{j,4};
                    center = (left+right)/2;
                    if ( abs(center-concentration) < max_error_match )
                        dataOnTable{j,1} = isSignificant;
                        dataOnTable{j,2} = concentration;
                        dataOnTable{j,3} = left;
                        dataOnTable{j,4} = right;
                        dataOnTable{j,5} = pScore;
                        dataOnTable{j,6} = isSignificant;
                        matched = true;
                        sourceBinBoundsMatched(i) = true;
                        break;
                    end
                end
                if ( ~matched )
                    matchingErrorString = ...
                        [matchingErrorString 10 13 ...
                        num2str(concentration, '%f') ...
                        ' not matched'];
                end
            end
            if ( ~isempty(matchingErrorString) )
                msgbox(['Unable to match the following loadings centers:' ...
                    10 13 matchingErrorString], ...
                    'Some bin loadings unable to be matched', ...
                    'warn', 'modal');
            end
            matchingErrorString = '';
            sBBMLen = length(sourceBinBoundsMatched);
            for i = 1:sBBMLen
                if ( ~sourceBinBoundsMatched(i) )
                    matchingErrorString = ...
                        [matchingErrorString 10 13  ...
                        'No loadings for bin number ' ...
                        num2str(i, '%d')];
                end
            end
            if ( ~isempty(matchingErrorString) )
                % Some of the source bin boundaries went unchecked and
                % unmatched. Report them.
                msgbox(['Unable to match the following bin boundaries:' ...
                    10 13 matchingErrorString], ...
                    'Some bin bounds unable to be matched', ...
                    'warn', 'modal');
            end
        end
    else
        msgbox(['Unable to open loadings file ' fullpath '!'], ...
            'Could not open file', 'error', 'modal');
    end;
    set(handles.binlist_uitable, 'Data', dataOnTable);
end;


% --- Executes on button press in save_binmap_subset_button.
function save_binmap_subset_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_binmap_subset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ( isfield(handles, 'binListCount') )
    [filename pathname] = uiputfile(...
        {'*.txt','Comma and Semicolon Delimited Binlist (*.txt)'; ...
        '*.*','All Files (*.*)'}, ...
        'Save subset bin list file...','selected_bins.txt');
    if ( ischar(filename) )
        fullpath = [pathname filename];
        fid = fopen(fullpath, 'w');
        if ( fid > 2 )
            dataOnTable = get(handles.binlist_uitable, 'Data');
            first = true;
            % DCW -- TODO: produce a subset, THEN print to file
            for i = 1:handles.binListCount
                % The "Include?" box was selected for this row.
                if ( dataOnTable{i,1} )
                    if ~first
                        fprintf(fid, ';');
                    end
                    fprintf(fid, '%f,%f', dataOnTable{i,2}, dataOnTable{i,3});
                    first = false;
                end;
            end;
            fprintf(fid, '\n');
            % Print the 'sum' strings;
            first = true;
            for i = 1:handles.binListCount
                if ( dataOnTable{i,1} )
                    % The "Include?" box was selected for this row.
                    if ~first
                        fprintf(fid, ';');
                    end
                    fprintf(fid, 'sum');
                    first = false;
                end;
            end;
            fclose(fid);
        else
            msgbox(['Unable to open target file ' fullpath '!'], ...
                'Could not open file', 'error', 'modal');
        end;
    end;
else
    msgbox('Please load a bin list file first.', ...
        'No bin list data to save', 'error', 'modal');
end;


function max_error_match_edit_Callback(hObject, eventdata, handles)
% hObject    handle to max_error_match_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_error_match_edit as text
%        str2double(get(hObject,'String')) returns contents of max_error_match_edit as a double


% --- Replace last occurrence of "Desc" in sourceString with "Asc"
function newString = replaceDescWithAsc(sourceString)
newString = regexprep(sourceString, 'Desc(.*)$', 'Asc$1');


% --- Replace last occurrence of "Asc" in sourceString with "Desc"
function newString = replaceAscWithDesc(sourceString)
newString = regexprep(sourceString, 'Asc(.*)$', 'Desc$1');


% --- Switches the "Asc" to "Desc" and vice-versa.
function switchSortDirLabel(hObject, sortMode)
if ( sortMode > 0 )
    set(hObject, 'String', ...
        replaceDescWithAsc(get(hObject, 'String')));
else
    set(hObject, 'String', ...
        replaceAscWithDesc(get(hObject, 'String')));
end;


% --- Executes on button press in sort_bounds_button.
function sort_bounds_button_Callback(hObject, eventdata, handles)
% hObject    handle to sort_bounds_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%msgbox(['Bounds button clicked. ' 10 13 ...
%    'hObject''s Tag property: ' get(hObject, 'Tag')], ...
%    '', 'help', 'modal');
if ( abs(handles.sortMode) == 1 )
    switchSortDirLabel(hObject, handles.sortMode);
    handles.sortMode = -handles.sortMode;
else
    handles.sortMode = 1;
end;
dataOnTable = get(handles.binlist_uitable, 'Data');
dataOnTable = sortrows(dataOnTable, 2);
if ( handles.sortMode > 0 )
    dataOnTable = flipud(dataOnTable);
end;
set(handles.binlist_uitable, 'Data', dataOnTable);
guidata(hObject, handles);


% --- Executes on button press in sort_prob_button.
function sort_prob_button_Callback(hObject, eventdata, handles)
% hObject    handle to sort_prob_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%msgbox(['Probability button clicked. ' 10 13 ...
%    'hObject''s Tag property: ' get(hObject, 'Tag')], ...
%    '', 'help', 'modal');
if ( abs(handles.sortMode) == 2 )
    switchSortDirLabel(hObject, handles.sortMode);
    handles.sortMode = -handles.sortMode;
else
    handles.sortMode = 2;
end;
dataOnTable = get(handles.binlist_uitable, 'Data');
dataOnTable = sortrows(dataOnTable, 5);
if ( handles.sortMode > 0 )
    dataOnTable = flipud(dataOnTable);
end;
set(handles.binlist_uitable, 'Data', dataOnTable);
guidata(hObject, handles);


% --- Executes on button press in sort_inclusion_button.
function sort_inclusion_button_Callback(hObject, eventdata, handles)
% hObject    handle to sort_inclusion_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Feature not yet implemented.','Sorry...','warn', 'modal');
%if ( abs(handles.sortMode) == 3 )
%    handles.sortMode = -handles.sortMode;
%else
%    handles.sortMode = 3;
%end;
%dataOnTable = get(handles.binlist_uitable, 'Data');
%dataOnTable = sortrows(dataOnTable, 1);
%if ( handles.sortMode > 0 )
%    dataOnTable = flipud(dataOnTable);
%end;
%set(handles.binlist_uitable, 'Data', dataOnTable);
%guidata(hObject, handles);


% --- Executes on button press in sort_sig_button.
function sort_sig_button_Callback(hObject, eventdata, handles)
% hObject    handle to sort_sig_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Feature not yet implemented.','Sorry...','warn', 'modal');
%if ( abs(handles.sortMode) == 4 )
%    handles.sortMode = -handles.sortMode;
%else
%    handles.sortMode = 4;
%end;
%dataOnTable = get(handles.binlist_uitable, 'Data');
%dataOnTable = sortrows(dataOnTable, 5);
%if ( handles.sortMode > 0 )
%    dataOnTable = flipud(dataOnTable);
%end;
%set(handles.binlist_uitable, 'Data', dataOnTable);
%guidata(hObject, handles);


% --- Executes on button press in clear_table_button.
function clear_table_button_Callback(hObject, eventdata, handles)
% hObject    handle to clear_table_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
app_init(hObject, handles)
