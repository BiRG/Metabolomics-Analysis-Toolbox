function varargout = targeted_identify(varargin)
% TARGETED_IDENTIFY MATLAB code for targeted_identify.fig
%      TARGETED_IDENTIFY, by itself, creates a new TARGETED_IDENTIFY or raises the existing
%      singleton*.
%
%      H = TARGETED_IDENTIFY returns the handle to a new TARGETED_IDENTIFY or the handle to
%      the existing singleton*.
%
%      TARGETED_IDENTIFY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TARGETED_IDENTIFY.M with the given input arguments.
%
%      TARGETED_IDENTIFY('Property','Value',...) creates a new TARGETED_IDENTIFY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before targeted_identify_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to targeted_identify_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help targeted_identify

% Last Modified by GUIDE v2.5 07-Jul-2011 10:27:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @targeted_identify_OpeningFcn, ...
                   'gui_OutputFcn',  @targeted_identify_OutputFcn, ...
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


% --- Executes just before targeted_identify is made visible.
function targeted_identify_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to targeted_identify (see VARARGIN)

% Choose default command line output for targeted_identify
handles.output = hObject;

% Initialize the collection and bin_map
if isappdata(0,'collection') && isappdata(0,'bin_map')
    % Move the app data from the matlab root into handle variables
    handles.collection = getappdata(0,'collection');
    handles.bin_map = getappdata(0,'bin_map');

    %Remove app data from matlab root so it is not sitting around
    rmappdata(0,'collection');
    rmappdata(0, 'bin_map');
else
    uiwait(msgbox('Either the bin_map or collections were not loaded.','Error','error','modal'));
    handles.collection = {};
    handles.bin_map =CompoundBin({1,'N methylnicotinamide',9.297,9.265,'s','Clean','CH2','Publication'});
end

% Initialize the menu of metabolites from the bin ma
num_bins = length(handles.bin_map);
metabolite_names{num_bins}='';
for bin_idx = 1:num_bins
    cur_bin = handles.bin_map(bin_idx);
    metabolite_names{bin_idx}=sprintf('%s (%d)', ...
        cur_bin.compound_descr, cur_bin.id);
end
set(handles.metabolite_menu, 'String', metabolite_names);

% Start with no identifications
handles.identifications = [];

% Start with peak_select tool selected
set(handles.select_peak_tool,'state','on');
handles.spectrum_idx = 1;
handles.bin_idx = 1;

% Initialize the display components
update_display(handles);
update_plot(handles);
zoom_to_bin(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes targeted_identify wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function num=num_identified_for_cur_metabolite(handles)
% Return the number of identified peaks for current metabolite
idents = handles.identifications;
if(isempty(idents))
    num = 0;
else
    bins = [idents.compound_bin];
    binids = bins([bins.id]==handles.bin_idx);
    num = length(binids);
end

function update_plot(handles)
% Update the plot - needed when the spectrum index changes
oldlims = xlim;
plot(handles.collection.x,handles.collection.Y(:,handles.spectrum_idx));
set(gca,'xdir','reverse');
if ~ (oldlims(1) == 0 && oldlims(2) == 1)
    xlim(oldlims)
end

function zoom_to_bin(handles)
% Set the plot boundaries to the current bin boundaries.  Needed when bin
% index changes (and at other times)
cb=handles.bin_map(handles.bin_idx);
xlim([cb.bin.right, cb.bin.left]);

function update_display(handles)
% Updates the various UI objects to reflect the state saved in the handles
% structure.  Needed when the spectrum index or the bin index changes
%
% handles The handles structure containing the GUI application state
set(handles.metabolite_menu, 'Value', handles.bin_idx);
cur_bin=handles.bin_map(handles.bin_idx);
set(handles.multiplicity_text,'String', strcat('Multiplicity: ', ...
    cur_bin.readable_multiplicity));
set(handles.proton_id_text,'String',strcat('Proton ID: ', ...
    cur_bin.proton_id));
set(handles.source_text,'String',strcat('Source: ', ...
    cur_bin.id_source));
set(handles.num_expected_peaks_text,'String', ...
    sprintf('Expected peaks: %d', cur_bin.num_peaks));
set(handles.spectrum_number_edit_box,'String', ...
    sprintf('%d', handles.spectrum_idx));
set(handles.num_identified_peaks_text,'String', ...
    sprintf('Identified peaks: %d', ...
    num_identified_for_cur_metabolite(handles)));
%TODO: finish - update

% --- Outputs from this function are returned to the command line.
function varargout = targeted_identify_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in previous_button.
function previous_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in zoom_to_bin_button.
function zoom_to_bin_button_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_to_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ---9.297,9.265,s,Clean,CH2,Publication-----------------------------------------------------------------
function select_peak_tool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to select_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function deselect_peak_tool_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to deselect_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in metabolite_menu.
function metabolite_menu_Callback(hObject, ~, handles)
% hObject    handle to metabolite_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metabolite_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metabolite_menu
handles.bin_idx = get(hObject,'Value');
update_display(handles);
zoom_to_bin(handles);
guidata(handles.figure1, handles);

% --- Executes during object creation, after setting all properties.
function metabolite_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metabolite_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spectrum_number_edit_box_Callback(hObject, eventdata, handles)
% hObject    handle to spectrum_number_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spectrum_number_edit_box as text
%        str2double(get(hObject,'String')) returns contents of spectrum_number_edit_box as a double


% --- Executes during object creation, after setting all properties.
function spectrum_number_edit_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrum_number_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --------------------------------------------------------------------
function turn_off_all_tools_but(handles, tool_name)
% TURN_OFF_ALL_BUT Turns off all tools in the toolbar but the tool with the given name
% tool_name The name of the tool to be left alone
if ~isequal(tool_name,'pan_tool')
    set(handles.pan_tool,'state','off');
end
if ~isequal(tool_name,'zoom_in_tool')
    set(handles.zoom_in_tool,'state','off');
end
if ~isequal(tool_name,'zoom_out_tool')
    set(handles.zoom_out_tool,'state','off');
end
if ~isequal(tool_name,'select_peak_tool')
    set(handles.select_peak_tool,'state','off');
end
if ~isequal(tool_name,'deselect_peak_tool')
    set(handles.deselect_peak_tool,'state','off');
end

% --------------------------------------------------------------------
function pan_tool_OnCallback(hObject, ~, handles)
% hObject    handle to pan_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turn_off_all_tools_but(handles, 'pan_tool');

% --------------------------------------------------------------------
function zoom_in_tool_OnCallback(hObject, ~, handles)
% hObject    handle to zoom_in_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turn_off_all_tools_but(handles, 'zoom_in_tool');

% --------------------------------------------------------------------
function zoom_out_tool_OnCallback(hObject, ~, handles)
% hObject    handle to zoom_out_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turn_off_all_tools_but(handles, 'zoom_out_tool');

% --------------------------------------------------------------------
function select_peak_tool_OnCallback(hObject, ~, handles)
% hObject    handle to select_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turn_off_all_tools_but(handles, 'select_peak_tool');

% --------------------------------------------------------------------
function deselect_peak_tool_OnCallback(hObject, ~, handles)
% hObject    handle to deselect_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
turn_off_all_tools_but(handles, 'deselect_peak_tool');
