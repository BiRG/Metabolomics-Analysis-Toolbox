function varargout = browse_spectra_bins(varargin)
% BROWSE_SPECTRA_BINS MATLAB code for browse_spectra_bins.fig
% Opens window to browse spectra and their relationship to a reference spectrum.
%      
%      use_bins=browse_spectra_bins({spectra, use_bins, use_spectra, display_indices})
%      opens the dialog to browse the spectra at display_indices in
%      spectra. spectra{s}.Y(b,s) contains the value for bin b measured
%      for spectrum s.
%      The whether a bin is selected is governed by use_bins.
%      use_bin(b) is true if for all c spectra{c}.x(b) should be
%      used as a bin when calculating the normalization constant, false 
%      otherwise. 
%
%      Input
%      -----
%      spectra         - a cell array of spectral collections as returned
%                        by load_collections.
%      use_bins        - use_bin(b) is true if for all c spectra{c}.x(b) 
%                        should be used as a bin when calculating the 
%                        normalization constant, false otherwise. 
%      use_spectra     - use_spectra{c}(s) is true if and only if
%                        spectra{c}.Y(:,s) should be used in calculating 
%                        the reference spectrum.
%      display_indices - display_indices(i,:) is a pair (c,s) meaning that
%                        spectrum{c}.Y(:,s) is the i'th spectrum to
%                        display. in the browser
% 
%      Output
%      ------
%      use_bins - the bins selected by the user during browsing (if
%                 cancelled, just returns the original bins).  This has the
%                 same format as the input variable of the same name.
%
%      BROWSE_SPECTRA_BINS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BROWSE_SPECTRA_BINS.M with the given input arguments.
%
%      BROWSE_SPECTRA_BINS('Property','Value',...) creates a new BROWSE_SPECTRA_BINS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before browse_spectra_bins_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to browse_spectra_bins_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help browse_spectra_bins

% Last Modified by GUIDE v2.5 12-May-2012 13:54:18

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @browse_spectra_bins_OpeningFcn, ...
                   'gui_OutputFcn',  @browse_spectra_bins_OutputFcn, ...
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


% --- Executes just before browse_spectra_bins is made visible.
function browse_spectra_bins_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to browse_spectra_bins (see VARARGIN)

% Choose default command line output for browse_spectra_bins
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes browse_spectra_bins wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = browse_spectra_bins_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function spectrum_properties_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to spectrum_properties_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in previous_button.
function previous_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to previous_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in close_button.
function close_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to close_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when selected object is changed in color_by_group.
function color_by_group_SelectionChangeFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to the selected object in color_by_group 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
