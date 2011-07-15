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

% Last Modified by GUIDE v2.5 14-Jul-2011 21:12:47

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

% Clear the table initially.
set(handles.binlist_uitable, 'Data', {});


% --- Outputs from this function are returned to the command line.
function varargout = select_bin_subset_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
        
        % -- DCW: Do the source bin bounds need to be sorted?
        %binBounds = [ binBounds{1} binBounds{2} ];
        %binBounds = flipud(sortrows(binBounds, 1));
        
        % Need the data to be stored in a cell of cells.
        vectorOfOnes = ones(1, handles.binListCount);
        %binBounds = mat2cell(binBounds, vectorOfOnes, [1 1]);
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
            logicalCellArray = mat2cell( ...
                false(handles.binListCount, 1), ...
                vectorOfOnes, 1);
            nanCellArray = mat2cell( ...
                NaN(handles.binListCount, 1), ...
                vectorOfOnes, 1);
            if ( isempty(dataOnTable) )
                binBounds = [ logicalCellArray binBounds ...
                    nanCellArray logicalCellArray ];
            else
                binBounds = [ dataOnTable(:, 1) binBounds ...
                    dataOnTable(:, 4) dataOnTable(:, 5) ];
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
        
        % -- DCW: Do the source loadings need to be sorted?
        %binLoadings = [ binLoadings{1} binLoadings{2} ...
        %    binLoadings{3} binLoadings{4} ];
        %binLoadings = flipud(sortrows(binLoadings, 1));
        
        % Need the data to be stored in a cell of cells.
        vectorOfOnes = ones(1, handles.binLoadingsCount);
        %binLoadings = mat2cell(binLoadings, vectorOfOnes, [1 1 1 1]);
        binLoadings = [ ...
            mat2cell(binLoadings{1}, vectorOfOnes, 1) ...
            mat2cell(binLoadings{2}, vectorOfOnes, 1) ...
            mat2cell(binLoadings{3}, vectorOfOnes, 1) ...
            mat2cell(logical(binLoadings{4}), vectorOfOnes, 1) ];
        
        if ( isfield(handles, 'binListCount') && ...
                handles.binListCount ~= handles.binLoadingsCount )
            msgbox(['Mismatched record counts!' 10 13 10 13 ...
                'Bin list record count: ' ...
                num2str(handles.binListCount) 10 13 ...
                'Bin loadings record count: ' ...
                num2str(handles.binLoadingsCount) ], ...
                'Unmatched file record counts','error','modal');
        else
            dataOnTable = get(handles.binlist_uitable, 'Data');
            nanCellArray = mat2cell( ...
                NaN(handles.binLoadingsCount, 1), ...
                vectorOfOnes, 1);
            if ( isempty(dataOnTable) )
                binLoadings = [ binLoadings(:,4) nanCellArray ...
                    nanCellArray binLoadings(:,3) binLoadings(:,4) ];
            else
                binLoadings = [ binLoadings(:,4) dataOnTable(:,2:3) ...
                    binLoadings(:,2) binLoadings(:,4) ];
            end;
            set(handles.binlist_uitable, 'Data', binLoadings);
        end;
    else
        msgbox(['Unable to open loadings file ' fullpath '!'], ...
            'Could not open file', 'error', 'modal');
    end;
end;


% --- Executes on button press in save_binlist_subset_button.
function save_binlist_subset_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_binlist_subset_button (see GCBO)
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
            source = get(handles.binlist_uitable, 'Data');
            for i = 1:handles.binListCount
                if ( source{i,1} )
                    % The "include?" box was selected for this row.
                    fprintf(fid, '%f,%f;', source{i,2}, source{i,3});
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
