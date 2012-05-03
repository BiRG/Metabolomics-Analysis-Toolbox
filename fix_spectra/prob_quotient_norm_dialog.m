function varargout = prob_quotient_norm_dialog(varargin)
% PROB_QUOTIENT_NORM_DIALOG MATLAB code for prob_quotient_norm_dialog.fig
%      Read this since it has been edited by a human.
%
%      [H, was_canceled, normalization_factors, processing_log_text] = prob_quotient_norm_dialog 
%      returns the normalization factors calculated for each of the spectra passed 
%      in the "binned_spectra" argument on the when the dialog was most 
%      recently raised or created. And returns a string to be added to the
%      processing log. The user should note what binning method was used to
%      create the original binned spectra in the processing log. If
%      was_canceled is true, then the normalization factors are invalid, as
%      is the processing log text. The user clicked the cancel button and
%      no normalization should be done.
%
%      prob_quotient_norm_dialog({binned_spectra, use_bin}) opens the
%      dialog to compute the normalization constants for all the spectra in
%      the struct array binned_spectra using the bins in the logical array
%      use_bin
%
%      PROB_QUOTIENT_NORM_DIALOG, by itself, creates a new PROB_QUOTIENT_NORM_DIALOG or raises the existing
%      singleton*.
%
%      H = PROB_QUOTIENT_NORM_DIALOG returns the handle to a new PROB_QUOTIENT_NORM_DIALOG or the handle to
%      the existing singleton*.
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

% Choose default command line output for prob_quotient_norm_dialog
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prob_quotient_norm_dialog wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prob_quotient_norm_dialog_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


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
function cancel_button_Callback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
