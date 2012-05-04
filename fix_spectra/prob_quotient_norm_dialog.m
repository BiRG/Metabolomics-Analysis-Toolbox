function varargout = prob_quotient_norm_dialog(varargin)
% PROB_QUOTIENT_NORM_DIALOG MATLAB code for prob_quotient_norm_dialog.fig
%      Read this since it has been edited by a human.
%
%      prob_quotient_norm_dialog({binned_spectra, use_bin}) opens the
%      dialog to compute the normalization constants for all the spectra in
%      the struct array binned_spectra using the bins in the logical array
%      use_bin
%
%      a = prob_quotient_norm_dialog(...)
%      Returns a cell array a composed of:
%        {H, was_canceled, normalization_factors, processing_log_text}.
%
%      H            is the handle to the dialog. 
%      was_canceled is true iff the user pressed cancel (in
%                   which case, none of the other factors are valid.
%      normalization_factors are the normalization factors calculated for 
%                   each of the spectra passed in the "binned_spectra" argument on 
%                   the when the dialog was most recently raised or created. 
%      processing_log_text is a string to be added to the processing log. 
%                   The user should note what binning method was used to
%                   create the original binned spectra in the processing 
%                   log. 
%
%      PROB_QUOTIENT_NORM_DIALOG, by itself, creates a new PROB_QUOTIENT_NORM_DIALOG or raises the existing
%      singleton*.
%
%      PROB_QUOTIENT_NORM_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROB_QUOTIENT_NORM_DIALOG.M with the given input arguments.
%
%      PROB_QUOTIENT_NORM_DIALOG('Property','Value',...) creates a new PROB_QUOTIENT_NORM_DIALOG or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prob_quotient_norm_dialog_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prob_quotient_norm_dialog_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prob_quotient_norm_dialog

% Last Modified by GUIDE v2.5 03-May-2012 18:04:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prob_quotient_norm_dialog_OpeningFcn, ...
                   'gui_OutputFcn',  @prob_quotient_norm_dialog_OutputFcn, ...
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


% --- Executes just before prob_quotient_norm_dialog is made visible.
function prob_quotient_norm_dialog_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prob_quotient_norm_dialog (see VARARGIN)

% Set default command line output for prob_quotient_norm_dialog to the same
% as a cancelled
handles.output = {hObject, true(1), ones(length(varargin{1,1}{1,1}),1), ...
    'No changes made during probabilistic quotient normalization'};

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prob_quotient_norm_dialog wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prob_quotient_norm_dialog_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

delete(handles.figure1);


% --- Executes on button press in normalize_button.
function normalize_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to normalize_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_bins_button.
function select_bins_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to select_bins_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in select_ref_spectra_button.
function select_ref_spectra_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to select_ref_spectra_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

uiresume(handles.figure1);

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

