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
[filename pathname] = uigetfile( ...
    {'*.txt','Comma and Semicolon Delimited Binlist (*.txt)'; ...
    '*.*','All Files (.*.*)'}, ...
    'Select Binlist file...','bins.txt');
if ( ischar(filename) )
    fid = fopen(filename);
    if ( fid > 2 )
        fclose(fid);
    else
    end;
end;


% --- Executes on button press in load_loadings_button.
function load_loadings_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_loadings_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename pathname] = uigetfile( ...
    {'*.csv;*.txt','Tab/Comma Delimited file (*.csv, *.txt)'; ...
    '*.*','All Files (.*.*)'}, ...
    'Select Binlist CSV file...','bins.csv');


% --- Executes on button press in save_binlist_subset_button.
function save_binlist_subset_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_binlist_subset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msgbox('Save Subset as Binlist button clicked');
