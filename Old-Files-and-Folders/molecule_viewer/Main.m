function varargout = Main(varargin)
% MAIN M-file for Main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Main

% Last Modified by GUIDE v2.5 06-May-2010 12:50:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Main_OpeningFcn, ...
                   'gui_OutputFcn',  @Main_OutputFcn, ...
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


% --- Executes just before Main is made visible.
function Main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Main (see VARARGIN)

addpath('../matlab_scripts');

% Choose default command line output for Main
handles.output = hObject;

set(hObject,'toolbar','figure');
set(handles.figure1,'CloseRequestFcn',@closeGUI);
if ismac
    set(handles.mainListTable,'ColumnWidth',{215});
elseif ispc
    set(handles.mainListTable, 'ColumnWidth', {135});    
end

% Loads the database file generated by "readinfiles.m", but will give
% priority to an edited library (created with the addCustMolecule function.
% a structure format.  This is then saved in handles as handles.molecules.
if((exist('molecules_library_edited.mat', 'file') > 0))
    load molecules_library_edited.mat
    handles.molecules = molecules;
elseif ((exist('molecules_library.mat', 'file') > 0))
    load molecules_library.mat
    handles.molecules = molecules;
else
    disp('Error Loading Library File');
end

% Takes the recently read in molecules structure and iterates through the 
% names of the molecules.  These are then printed to the master table.
set(handles.mainListTable,'ColumnName',{'Molecule'});
data = cell(length(handles.molecules),1);
for m = 1:length(handles.molecules)
    data{m,1} = handles.molecules(m).moleculeName;
end

% Passes the information to the table object.
set(handles.mainListTable,'data',data);

% Sets up an array for later use.
handles.moleculeSelection = [];
handles.molecule_inxs = 1:length(handles.molecules);

% Sets up an array for later use.
handles.spectraSelection = [];

% Set up the spectra array
handles.spectra = {};

% Clear spectra table
set(handles.spectra_uitable,'data',{});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when trying to close the GUI figure1.
function closeGUI(src,evnt)
% src is the handle of the object generating the callback (the source of the event)
% evnt is the The event data structure (can be empty for some callbacks)
selection = questdlg('Do you want to close this window?',...
                     'Confirmation Window',...
                     'Yes','No','Yes');
switch selection,
   case 'Yes',
    delete(gcf)
   case 'No'
     return
end


% --- Executes on button press in showButton.
function showButton_Callback(hObject, eventdata, handles)
% hObject    handle to showButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

h_main = gcf;
h_view_molecule = view_molecule;
% set(view_molecule_handles.height_slider,'Min',0);
% set(view_molecule_handles.height_slider,'Max',1);
% set(view_molecule_handles.height_slider,'Value',1);
show_molecule(h_main,h_view_molecule,handles.molecules(handles.molecule_inxs(handles.moleculeSelection)));

% --- Executes on button press in addCustMolButton.
function addCustMolButton_Callback(hObject, eventdata, handles)
% hObject    handle to addCustMolButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

AddCustMolecule();


% --- Executes on button press in addCustListButton.
function addCustListButton_Callback(hObject, eventdata, handles)
% hObject    handle to addCustListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ListSubsetEditer();


% --- Executes on button press in loadCustListButton.
function loadCustListButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadCustListButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.mat', 'Pick A Subset: ');
if isequal(filename,0) || isequal(pathname,0)
   disp('User pressed cancel')
else
    load(strcat(pathname,filename));
    handles.molecules = tempMolecules;
end


% Recalculates the subsetTable's contents.
data = cell(length(handles.molecules),1);
for m = 1:length(handles.molecules)
    data{m,1} = handles.molecules(m).moleculeName;
end

% Passes the information to the table object.
set(handles.mainListTable,'data',data);

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in mainListTable.
function mainListTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to mainListTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

% Grabs the row that is selected on the table and stores it in "row".
% Then sends row to a handles object that can be used by the buttons! 
row = eventdata.Indices(1,1);
handles.moleculeSelection = row;

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ismac
    set(handles.mainListTable,'ColumnWidth',{140});
end

% Loads the database file generated by "readinfiles.m", but will give
% priority to an edited library (created with the addCustMolecule function.
% a structure format.  This is then saved in handles as handles.molecules.
if((exist('molecules_library_edited.mat', 'file') > 0))
    load molecules_library_edited.mat
    handles.molecules = molecules;
elseif ((exist('molecules_library.mat', 'file') > 0))
    load molecules_library.mat
    handles.molecules = molecules;
else
    disp('Error Loading Library File');
end

% Takes the recently read in molecules structure and iterates through the 
% names of the molecules.  These are then printed to the master table.
set(handles.mainListTable,'ColumnName','Molecule');
data = cell(length(handles.molecules),1);
for m = 1:length(handles.molecules)
    data{m,1} = handles.molecules(m).moleculeName;
end

% Passes the information to the table object.
set(handles.mainListTable,'data',data);

% Sets up an array for later use.
handles.moleculeSelection = [];

% Update handles structure
guidata(hObject, handles);


% --- Executes on selection change in nmrTypeFilter.
function nmrTypeFilter_Callback(hObject, eventdata, handles)
% hObject    handle to nmrTypeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns nmrTypeFilter contents as cell array
%        contents{get(hObject,'Value')} returns selected item from nmrTypeFilter

val = get(handles.nmrTypeFilter,'Value');
if val == 1
    disp('hydrogen');
    
%     counter = 1;
%     tempSubSetMolecules = struct('file', '', 'peakNumbers', 0, 'ppm', 0, 'hz', 0,...
%         'peakHeight', 0, 'moleculeName', '');
% 
% 
%     % Filters out the file to be removed based on file name and repopulates the
%     % tempSubSetMolecules structure with the new infomation.
%     for m = 1:length(handles.molecules)
%         if((strcmp(handles.molecules(m).type,'H')))
%             tempSubSetMolecules(counter) = handles.molecules(m);
%         else
%             % disp(strcat('Removed file: ', num2str(handles.molecules(m))));
%         end
%     end
% 
%     handles.molecules = tempSubSetMolecules;
% 
%     fixTable2Size = cell(length(handles.subSetMolecules),1);
%     set(handles.subsetListTable,'data',fixTable2Size);
% 
%     % Recalculates the subsetTable's contents.
%     data = cell(length(handles.molecules),1);
%     for m = 1:length(handles.molecules)
%         data{m,1} = handles.molecules(m).moleculeName;
%     end
% 
%     % Passes the information to the table object.
%     set(handles.subsetListTable,'data',data);
elseif val == 2
    disp('carbon');
elseif val == 3
    disp('phosphorus');
end

% --- Executes during object creation, after setting all properties.
function nmrTypeFilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nmrTypeFilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on mouse press over figure background, over a disabled or
% --- inactive control, or over an axes background.
function figure1_WindowButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% This supresses the error caused when you click on the background of main
% window.


% --- Executes on button press in get_collections_button.
function get_collections_button_Callback(hObject, eventdata, handles)
% hObject    handle to get_collections_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collections = get_collections;
add_collections(collections,hObject,handles);

% --- Executes on button press in load_collections_button.
function load_collections_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_collections_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% try
%     right_noise = str2num(get(handles.right_noise_edit,'Value'));
%     left_noise = str2num(get(handles.left_noise_edit,'Value'));
% catch ME
%     msgbox('Invalid noise region');
%     return;
% end

collections = load_collections;
add_collections(collections,hObject,handles);

function add_collections(collections,hObject,handles)

% Takes the recently read in molecules structure and iterates through the 
% names of the molecules.  These are then printed to the master table.
data = get(handles.spectra_uitable,'data');
set(handles.spectra_uitable,'ColumnName',{'Description','Time','Classification','Subject ID','Sample ID'});
for c = 1:length(collections)
    for s = 1:collections{c}.num_samples
        handles.spectra{end+1} = {};
        handles.spectra{end}.x = collections{c}.x;
        handles.spectra{end}.y = collections{c}.Y(:,s);
        data{end+1,1} = collections{c}.description;
        if iscell(collections{c}.time)
            data{end,2} = collections{c}.time{s};
        else
            data{end,2} = collections{c}.time(s);
        end
        if iscell(collections{c}.classification)
            data{end,3} = collections{c}.classification{s};
        else
            data{end,3} = collections{c}.classification(s);
        end
        if iscell(collections{c}.subject_id)
            data{end,4} = collections{c}.subject_id{s};
        else
            data{end,4} = collections{c}.subject_id(s);
        end
        if iscell(collections{c}.sample_id)
            data{end,5} = collections{c}.sample_id{s};
        else
            data{end,5} = collections{c}.sample_id(s);
        end
    end
end

% Passes the information to the table object.
set(handles.spectra_uitable,'data',data);

% Update handles structure
guidata(hObject, handles);


% --- Executes when selected cell(s) is changed in spectra_uitable.
function spectra_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to spectra_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

row = eventdata.Indices(1,1);
handles.spectraSelection = row;

axes(handles.axes1);
plot(handles.spectra{handles.spectraSelection}.x,handles.spectra{handles.spectraSelection}.y,'k-');
xlabel('Chemical shift, ppm');
ylabel('Intensity');
set(gca,'xdir','reverse');

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in preview_button.
function preview_button_Callback(hObject, eventdata, handles)
% hObject    handle to preview_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.spectraSelection)
    msgbox('Please select a spectrum');
    return;
end

if isempty(handles.moleculeSelection)
    msgbox('Please select a molecule');
    return;
end

spectrum = handles.spectra{handles.spectraSelection};
x = spectrum.x;

try
    delete(handles.h_preview);
catch ME
end

% Create spectrum for molecule using defaults
molecule = handles.molecules(handles.molecule_inxs(handles.moleculeSelection));
% Create spectrum for molecule using defaults
default_width = 0.005;
MGPX = [];
for p = 1:length(molecule.ppm)
    MGPX = [MGPX,molecule.peakHeight(p),default_width,0,molecule.ppm(p)];
end
y_peaks = global_model(MGPX,x,length(MGPX)/4,[]);

% Break the peaks into groups
height_cutoff = 0.001; % Change to actually specify multiplets later
groups = [];
looking_to_start = true;
for i = 1:length(x)
    if looking_to_start
        if y_peaks(i) > height_cutoff
            groups(end+1,1) = i;
            looking_to_start = false;
        end
    else
        if y_peaks(i) < height_cutoff
            groups(end,2) = i;
            looking_to_start = true;
        end
    end
end
[num_groups,temp] = size(groups);       

y_peaks = 0*x;
for g = 1:num_groups
    peak_inxs = find(x(groups(g,1)) >= molecule.ppm & molecule.ppm >= x(groups(g,2)));
    shift = molecule.best_shifts(g);
    % Create y_peaks for this multiplet
    MGPX = [];
    for i = 1:length(peak_inxs)
        p = peak_inxs(i);
        MGPX = [MGPX,molecule.peakHeight(p),default_width,0,molecule.ppm(p)+shift];
    end
    y_peaks = y_peaks + molecule.best_height*global_model(MGPX,x,length(MGPX)/4,[]);
end

axes(handles.axes1);
handles.h_preview = line(x,y_peaks);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in rank_button.
function rank_button_Callback(hObject, eventdata, handles)
% hObject    handle to rank_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.spectraSelection)
    msgbox('Please select a spectrum');
    return;
end

spectrum = handles.spectra{handles.spectraSelection};
x = spectrum.x;
y = spectrum.y;

height_cutoff = 0.001; % Change to actually specify multiplets later
default_width = 0.005; % Just a preview
num_heights_to_try = 10;
num_shifts_to_try = 10;
max_shift = str2num(get(handles.max_shift_edit,'String'));
xl = get(handles.axes1,'xlim');
preview_left = xl(2);
preview_right = xl(1);
preview_inxs = find(preview_left >= x & x >= preview_right);
[preview_max_height,temp] = max(y(preview_inxs));
loc_max = x(preview_inxs(temp));
preview_min_height = min([preview_max_height - y(preview_inxs(1)),preview_max_height - y(preview_inxs(end))]);
% Now add in shift
preview_left = loc_max + max_shift;
preview_right = loc_max - max_shift;

% for each molecule
scores = NaN*ones(size(handles.molecules));
for m = 1:length(handles.molecules)
    molecule = handles.molecules(m);
    % Make sure there is a peak from this molecule within max_shift
    preview_peaks = find(preview_left >= molecule.ppm & molecule.ppm >= preview_right);
    if isempty(preview_peaks)
        handles.molecules(m).best_SSE = Inf;
        handles.molecules(m).best_shifts = [];
        handles.molecules(m).best_height = NaN;
        handles.molecules(m).score = Inf;
        scores(m) = Inf;
    else
        % Determine the maximum and minimum heights
        max_height = NaN;
        min_height = NaN;
        for i = 1:length(preview_peaks)
            height = molecule.peakHeight(preview_peaks(i));
            temp_max_height = preview_max_height/height;
            if isnan(max_height) || temp_max_height > max_height
                max_height = temp_max_height;
            end
            temp_min_height = preview_min_height/height;
            if isnan(min_height) || temp_min_height < min_height
                min_height = temp_min_height;
            end
        end

        % Create spectrum for molecule using defaults
        MGPX = [];
        for p = 1:length(molecule.ppm)
            MGPX = [MGPX,molecule.peakHeight(p),default_width,0,molecule.ppm(p)];
        end
        y_peaks = global_model(MGPX,x,length(MGPX)/4,[]);

        % Break the peaks into groups
        groups = [];
        looking_to_start = true;
        for i = 1:length(x)
            if looking_to_start
                if y_peaks(i) > height_cutoff
                    groups(end+1,1) = i;
                    looking_to_start = false;
                end
            else
                if y_peaks(i) < height_cutoff
                    groups(end,2) = i;
                    looking_to_start = true;
                end
            end
        end
        [num_groups,temp] = size(groups);

        % Find the best heights using the preview peaks
        heights = linspace(min_height,max_height,num_heights_to_try);
        best_SSE = Inf; % Varying height
        best_height = NaN;
        best_shifts = [];
        for h = 1:length(heights)
            height = heights(h);
            % For each group (i.e., multiplet)
            best_shifts_shift = NaN*ones(1,num_groups);
            best_SSE_shift = Inf*ones(1,num_groups);
            for g = 1:num_groups
                peak_inxs = find(x(groups(g,1)) >= molecule.ppm & molecule.ppm >= x(groups(g,2)));
                % See if this group is in the preview window
                in_preview_window = false;
                if ~isempty(find(preview_left >= molecule.ppm(peak_inxs) & molecule.ppm(peak_inxs) >= preview_right))
                    preview_peaks_x = molecule.ppm(preview_peaks);
                    shifts = loc_max - preview_peaks_x;
                    in_preview_window = true;
                else
                    shifts = linspace(-max_shift,max_shift,min([num_shifts_to_try,round(2*max_shift/abs(x(1)-x(2)))]));
                end
                % Go through shifts
                for s = 1:length(shifts)
                    shift = shifts(s);
                    % Create y_peaks for this multiplet
                    MGPX = [];
                    for i = 1:length(peak_inxs)
                        p = peak_inxs(i);
                        MGPX = [MGPX,molecule.peakHeight(p),default_width,0,molecule.ppm(p)+shift];
                    end
                    y_peaks = height*global_model(MGPX,x',length(MGPX)/4,[]);
                    % Now compute the score at the peak locations only
                    % (ignoring shape)
                    peak_x_inxs = round((x(1) - molecule.ppm(peak_inxs))/(x(1)-x(2))) + 1;
                    if in_preview_window
                        temp_SSE = 10*sum((y_peaks(peak_x_inxs)-y(peak_x_inxs)).^2); % More important
                    else
                        temp_SSE = sum((y_peaks(peak_x_inxs)-y(peak_x_inxs)).^2);
                    end
                    if temp_SSE < best_SSE_shift(g)
                        best_SSE_shift(g) = temp_SSE;
                        best_shifts_shift(g) = shift;
                    end
                end
            end
            temp_SSE = sum(best_SSE_shift);
            if temp_SSE < best_SSE
                best_SSE = temp_SSE;
                best_shifts = best_shifts_shift;
                best_height = height;
            end
        end
        handles.molecules(m).best_SSE = best_SSE;
        handles.molecules(m).score = best_SSE/length(molecule.ppm);
        scores(m) = handles.molecules(m).score;
        handles.molecules(m).best_shifts = best_shifts;
        handles.molecules(m).best_height = best_height;
    end
    fprintf('Molecule %d/%d\n',m,length(handles.molecules));
end

set(handles.mainListTable,'ColumnName',{'Molecule','Score'});
data = cell(length(handles.molecules),2);
[vs,inxs] = sort(scores,'ascend');
handles.molecule_inxs = inxs;
for i = 1:length(inxs)
    m = inxs(i);
    data{i,1} = handles.molecules(m).moleculeName;
    data{i,2} = handles.molecules(m).score;
end
set(handles.mainListTable,'data',data);

msgbox('Finished ranking molecules');

% Update handles structure
guidata(hObject, handles);


function max_shift_edit_Callback(hObject, eventdata, handles)
% hObject    handle to max_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_shift_edit as text
%        str2double(get(hObject,'String')) returns contents of max_shift_edit as a double


% --- Executes during object creation, after setting all properties.
function max_shift_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_shift_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
