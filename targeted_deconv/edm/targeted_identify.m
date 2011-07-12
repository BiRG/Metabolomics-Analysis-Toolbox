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

% Last Modified by GUIDE v2.5 12-Jul-2011 17:09:56

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

% Start witn no detected peaks (but preallocate the array)
handles.peaks = zeros(num_bins, handles.collection.num_samples);

% Start with no tool selected
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


function pks = get_peaks(bin_idx, spectrum_idx, handles)
% Return the peaks for the given bin in the given spectrum.  Either uses
% those already calculated and/or modified by the user or (if they haven't
% been calculated yet) calculates them.
%
% bin_idx       The index of the bin where the peaks lie
% spectrum_idx  The index of the spectrum in the current collection where
%               the peaks lie
% handles       The user and GUI data structure
pks = handles.peaks(bin_idx, spectrum_idx);
if isempty(pks)
    %TODO: detect peaks
end


function set_peaks(bin_idx, spectrum_idx, newval, handles)
% Set the peaks for the given bin in the given spectrum.  Updates the gui
% and the guidata stored in handles.figure1.
%
% bin_idx       The index of the bin where the peaks lie
% spectrum_idx  The index of the spectrum in the current collection where
%               the peaks lie
% new_val       The new value to use for the peaks
% handles       The user and GUI data structure

%TODO: set peaks and update the gui




function ids=peak_identifications_for_cur_metabolite(handles)
% Return the list of the peaks identified for the current metabolite
idents = handles.identifications;
if(isempty(idents))
    ids = [];
else
    bins = [idents.compound_bin];
    correct_bin = [bins.id]==handles.bin_map(handles.bin_idx).id;
    specs = [idents.spectrum_index];
    correct_spec = specs == handles.spectrum_idx;
    ids = idents(correct_bin & correct_spec);
end

function num=num_identified_for_cur_metabolite(handles)
% Return the number of identified peaks for current metabolite
num = length(peak_identifications_for_cur_metabolite(handles));

function draw_circle(center, radius_inches, color)
% Draws a circle on the current axes at the center location (in data 
% coordinates).  The radius of the circle drawn is in inches.
%
% center        The center of the circle to draw (in data coordinates).
%               Pass as [x y]
% radius_inches The radius of the circle as plotted on the screen in inches
% color         The color of the circle to plot
center_x = center(1);
center_y = center(2);
oldunits = get(gca, 'Units');
set(gca, 'Units','inches');
rect = get(gca, 'Position'); %Bounding rectangle for plot in pixels
width = rect(3);
height = rect(4);
set(gca, 'Units', oldunits);

xl = xlim;
yl = ylim;

rx = radius_inches*(xl(2)-xl(1))/width;  %X radius
ry = radius_inches*(yl(2)-yl(1))/height; %Y radius
rectangle('Position', ...
        [center_x-rx, center_y-ry, 2*rx, 2*ry], ...
        'Curvature', [1,1], 'EdgeColor', color);

function draw_identification(peak_id_obj, collection)
% Draws the selected peak identification on the current plot
%
% peak_id_obj The PeakIdentification object to draw
% collection  The collection referenced by that object
pid = peak_id_obj;
spectrum = collection.Y(:,pid.spectrum_index);
center = [pid.ppm, spectrum(pid.height_index)];
draw_circle(center, 0.0625, 'g');

function update_plot(handles)
% Update the plot - needed when the spectrum index changes or the
% identifications change
oldlims = xlim;
plot(handles.collection.x,handles.collection.Y(:,handles.spectrum_idx));
set(gca,'xdir','reverse');
if ~ (oldlims(1) == 0 && oldlims(2) == 1)
    xlim(oldlims)
end

for id=peak_identifications_for_cur_metabolite(handles)
    draw_identification(id, handles.collection);
end

%Reset the button-down function on the generated plot
set(gca,'ButtonDownFcn',@spectrum_plot_ButtonDownFcn);

%Make the child-objects non-clickable so that all clicks are on the axes
%object
children = get(gca,'Children');
for child_handle=children
    set(child_handle, 'HitTest', 'off');
end

function zoom_to_bin(handles)
% Set the plot boundaries to the current bin boundaries.  Needed when bin
% index changes (and at other times)
cb=handles.bin_map(handles.bin_idx);
xlim([cb.bin.right, cb.bin.left]);
ylim('auto');

function update_display(handles)
% Updates the various UI objects to reflect the state saved in the handles
% structure.  Needed when the spectrum index or the bin index or 
% identifications list changes
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

bin_idx = handles.bin_idx;
num_bins = length(handles.bin_map);
num_spec = handles.collection.num_samples;
spec_idx = handles.spectrum_idx;
if spec_idx == 1
    if bin_idx == 1
        set(handles.previous_button, 'String', 'No previous');
        set(handles.previous_button, 'Enable', 'off');
    else
        set(handles.previous_button, 'String', 'Previous bin');
        set(handles.previous_button, 'Enable', 'on');
    end
elseif spec_idx > 1
    set(handles.previous_button, 'String', 'Previous spectrum');
    set(handles.previous_button, 'Enable', 'on');
end

if spec_idx == num_spec
    if bin_idx == num_bins
        set(handles.next_button, 'String', 'Finish');
        set(handles.next_button, 'Enable', 'on');
    else
        set(handles.next_button, 'String', 'Next bin');
        set(handles.next_button, 'Enable', 'on');
    end
elseif spec_idx < num_spec
    set(handles.next_button, 'String', 'Next spectrum');
    set(handles.next_button, 'Enable', 'on');    
end
%TODO: finish - update plot and 'cleanness'

% --- Outputs from this function are returned to the command line.
function varargout = targeted_identify_OutputFcn(~, ~, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in previous_button.
function previous_button_Callback(~, ~, handles)
% hObject    handle to previous_button (see GCBO) - this is the first argument 
%            (that is now replaced by ~) 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bin_idx = handles.bin_idx;
spec_idx = handles.spectrum_idx;
if spec_idx > 1
    set_spectrum_idx(spec_idx-1, handles);
else 
    num_spec = handles.collection.num_samples;
    if bin_idx > 1
        set_spectrum_and_bin_idx(num_spec, bin_idx-1, handles);
        uiwait(msgbox('Changing to previous compound', ...
            'Changing to previous compound','modal'));
    else
        uiwait(msgbox('This is the first spectrum in the first bin.', ...
            'Can''t go before first spectrum','modal'));
    end
end


% --- Executes on button press in next_button.
function next_button_Callback(~, ~, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bin_idx = handles.bin_idx;
spec_idx = handles.spectrum_idx;
num_spec = handles.collection.num_samples;
if spec_idx < num_spec
    set_spectrum_idx(spec_idx+1, handles);
else 
    num_bins = length(handles.bin_map);
    if bin_idx < num_bins
        set_spectrum_and_bin_idx(1, bin_idx+1, handles);
        uiwait(msgbox('Changing to next compound', ...
            'Changing to next compound','modal'));
    else
        uiwait(msgbox('Will run finishing code here', ...
            'Placeholder dialog', 'modal'));
        %TODO: write code for finishing
    end
end


% --- Executes on button press in zoom_to_bin_button.
function zoom_to_bin_button_Callback(~, ~, handles)
% hObject    handle to zoom_to_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom_to_bin(handles);

% --- Executes on selection change in metabolite_menu.
function metabolite_menu_Callback(hObject, ~, handles)
% hObject    handle to metabolite_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metabolite_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metabolite_menu
set_bin_idx(get(hObject,'Value'), handles);

% --- Executes during object creation, after setting all properties.
function metabolite_menu_CreateFcn(hObject, ~, ~)
% hObject    handle to metabolite_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function set_identifications(new_identifications, handles)
handles.identifications = new_identifications;
guidata(handles.figure1, handles);
update_display(handles);
update_plot(handles);

function set_spectrum_and_bin_idx(new_spec, new_bin, handles)
% Sets handles.spectrum_idx and handles.bin_idx and also updates the gui 
% I believe (though I haven't verified) that the value in handles in the 
% caller will be unchanged.
handles.spectrum_idx = new_spec;
handles.bin_idx = new_bin;
guidata(handles.figure1, handles);
update_display(handles);
update_plot(handles);
zoom_to_bin(handles);


function set_spectrum_idx(new_val, handles)
% Sets handles.spectrum_idx and also updates the gui - don't call when you
% update the bin_idx to avoid repeating updates.  I believe (though I
% haven't verified) that the value in handles in the caller will be
% unchanged.
%
% new_val   the new value of the spectrum_idx
% handles   structures with handles and user data
handles.spectrum_idx = new_val;
guidata(handles.figure1, handles);
update_display(handles);
update_plot(handles);

function set_bin_idx(new_val, handles)
% Sets handles.bin_idx and also updates the gui - don't call when you
% update the bin_idx to avoid repeating updates.  I believe (though I
% haven't verified) that the value in handles in the caller will be
% unchanged.
%
% new_val   the new value of the bin_idx
% handles   structures with handles and user data
handles.bin_idx = new_val;
guidata(handles.figure1, handles);
update_display(handles);
zoom_to_bin(handles);

function spectrum_number_edit_box_Callback(hObject, ~, handles)
% hObject    handle to spectrum_number_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spectrum_number_edit_box as text
%        str2double(get(hObject,'String')) returns contents of spectrum_number_edit_box as a double
entry  = str2double(get(hObject,'String'));
if ~isnan(entry) %If the user typed a number
    entry = round(entry);
    if (entry >= 1) && (entry <= handles.collection.num_samples)
        set_spectrum_idx(entry, handles);
    else
        uiwait(msgbox( ...
            sprintf('Invalid spectrum number.  There are only %d spectra.', ...
                handles.collection.num_samples), 'Error','error','modal'));
    end
end

% --- Executes during object creation, after setting all properties.
function spectrum_number_edit_box_CreateFcn(hObject, ~, ~)
% hObject    handle to spectrum_number_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function reset_plot_to_non_interactive(handles)
% Disables interactive panning or zoom mode 
zoom(handles.figure1, 'off');
pan(handles.figure1, 'off');

% --------------------------------------------------------------------
function select_peak_tool_ClickedCallback(hObject, ~, handles)
% hObject    handle to select_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
putdowntext('thisisnotamatlabbutton',hObject); % Call undocumented matlab toolbar button change routine
reset_plot_to_non_interactive(handles);

% --------------------------------------------------------------------
function deselect_peak_tool_ClickedCallback(hObject, ~, handles)
% hObject    handle to deselect_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
putdowntext('thisisnotamatlabbutton',hObject); % Call undocumented matlab toolbar button change routine
reset_plot_to_non_interactive(handles);

function idx = min_idx(vals)
min_val = min(vals);
idx = find(vals == min_val, 1, 'first');

function idx = index_of_nearest_point_to(target, points_x, points_y)
% Return the index of the point closest to target in the points described
% by points_x and points_y
%deselect_peak_tool_ClickedCallback
% target   the point whose closest neighbor is being found (in form [x y] )
% points_x the x coordinates of the neighbor points
% points_y the y coordinates of the neighbor points
dx = points_x - target(1);
dy = points_y - target(2);
dists = sqrt(dx.^2+dy.^2);
idx = min_idx(dists);

function idx = index_of_nearest_x_to(val, handles)
% Return the index of the value closest to val in the x values of the
% collection.
%
% handles structure with handles and user data (see GUIDATA)
xvals = handles.collection.x;
diffs = abs(val - xvals);
idx = min_idx(diffs);

% --- Executes on mouse press over axes background.
function spectrum_plot_ButtonDownFcn(hObject, ~, ~)
% hObject    handle to spectrum_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% If called on a graphics object, set to the containing axes object
if ~strcmpi(get(hObject,'Type'),'axes')
   hObject = findobj('Children',hObject);
end

% Get the coordinates
mouse_pos = get(hObject,'CurrentPoint');
if ~isequal(size(mouse_pos), [2,3])
    uiwait(msgbox('Please click elsewhere.','Please click elsewhere.',...
        'modal'));
    return;
end
x_pos = mouse_pos(1,1);
y_pos = mouse_pos(1,2);

% Get the handles structure
fig1=get(hObject,'Parent');
handles = guidata(fig1);

% Run the appropriate tool
if isequal(get(handles.select_peak_tool, 'state'),'on')
    %Select peak
    xidx = index_of_nearest_x_to(x_pos, handles);
    newid = PeakIdentification(x_pos, xidx, handles.spectrum_idx, ...
        handles.bin_map(handles.bin_idx));
    set_identifications([handles.identifications newid],handles);
elseif isequal(get(handles.deselect_peak_tool, 'state'),'on')
    
    %Deselect peak
    ids = peak_identifications_for_cur_metabolite(handles);
    id_x = [ids.ppm];
    id_idx = [ids.height_index];
    id_y = handles.collection.Y(:, handles.spectrum_idx);
    id_y = (id_y(id_idx))';
    idx = index_of_nearest_point_to([x_pos, y_pos], id_x, id_y);
    to_remove = ids(idx);
    new_ids = handles.identifications;
    new_ids(new_ids == to_remove) = [];
    set_identifications(new_ids, handles);
end
%TODO: finish button down for spectrum plot

function dont_call_this_function_it_exists_to_remove_spurious_warnings()
% This function calls all those functions that matlab erroneously thinks
% are not called when this function doesn't call them.
 previous_button_Callback(hObject, eventdata, handles)
 next_button_Callback;
 zoom_to_bin_button_Callback;
 metabolite_menu_Callback;
 select_peak_tool_ClickedCallback;
 deselect_peak_tool_ClickedCallback;
 spectrum_number_edit_box_Callback;
 spectrum_number_edit_box_CreateFcn;
 metabolite_menu_CreateFcn;
 dont_call_this_function_it_exists_to_remove_spurious_warnings;


