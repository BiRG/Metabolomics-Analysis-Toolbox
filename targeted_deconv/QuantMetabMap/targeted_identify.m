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

% Last Modified by GUIDE v2.5 05-Dec-2012 19:55:59

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


% ------------------------------------------------------------------------
%
% Initialization and OpeningFncn
%
% ------------------------------------------------------------------------


function col=bogus_collection
% Return a collection object just made up as a space filler when the gui is
% started in an inappropriate manner
col.filename = 'not a real file';
col.input_names={'Collection ID','Type','Description',...
    'Processing log','Base sample ID','Time','Classification',...
    'Sample ID','Subject ID','Sample Description','Weight',...
    'Units of weight','Species'};
col.x=[1 2 3];
col.Y=[1 5 1]';
col.num_samples=1;
col.collection_id='-100';
col.type='SpectraCollection';
col.description=['Bogus data used for testing ',...
    'targeted_identify.m'];
col.processing_log='No processing done';
col.base_sample_id=1;
col.time=0;
col.classification={'no_class'};
col.sample_id={'no_sample_id'};
col.subject_id={1};
col.sample_description={'no_descr'};
col.weight={'no_weight'};
col.units_of_weight={'no_units'};
col.species={'no_species'};

function out_handles = init_handles_and_gui_from_session_data(handles, session_data)
% Given saved session data (in session_data) as well as handles to the gui 
% components, in handles, initializes the gui and user data from that saved
% session.  Returns the new value of the handles object after the saved 
% user data has been restored to it
%
% Note that display components are not initialized 
if(session_data.version ~= 0.3)
    % TODO: handle session data for version 0.4
    uiwait(msgbox(['This session data was generated from a ', ...
        'different version of the targeted deconvolution program (#', ...
        sprintf('%0.2f',session_data.version), ...
        ')  Things may not work as expected.'],'Warn','Warn'));
end

set(handles.metabolite_menu,'String', session_data.metabolite_menu_string);
handles.collection = session_data.collection;
if session_data.version >= 0.3
    handles.metab_map = session_data.metab_map;
else
    % In earlier versions, metab_map was called bin_map.  The name was
    % changed due to confusion with a bin map that was just a listing of
    % bin boundaries.
    handles.metab_map = session_data.bin_map;
end
handles.identifications = session_data.identifications;
handles.peaks = session_data.peaks;
handles.spectrum_idx = session_data.spectrum_idx;
handles.bin_idx = session_data.bin_idx;
handles.already_autoidentified = session_data.already_autoidentified;
handles.deconvolutions = session_data.deconvolutions;

if session_data.version < 0.2
    % In earlier versions, there were no model objects, so set the models to
    % the default
    num_spec = collection.num_samples;
    num_bins = length(metab_map);
    handles.models(num_bins, num_spec)=RegionalSpectrumModel;
else
    % Otherwise set to the saved models
    handles.models = session_data.models;
end

out_handles = handles;


function out_handles = init_handles_and_gui_from_scratch(handles)
% Takes a handles structure that has handles for the gui components, a
% metab_map and a collection as well as possibly a peaks cell array, and 
% initializes the rest of the gui state from that.  Returns the new value 
% for the handles structure
%
% Note that display components are not initialized 

% Initialize the menu of metabolites from the metab map
num_bins = length(handles.metab_map);
num_samples = handles.collection.num_samples;
metabolite_names{num_bins}='';
for bin_idx = 1:num_bins
    cur_bin = handles.metab_map(bin_idx);
    metabolite_names{bin_idx}=sprintf('%s (%d)', ...
        cur_bin.compound_name, cur_bin.id);
end
set(handles.metabolite_menu, 'String', metabolite_names);

% Start with no identifications
handles.identifications = [];

% Start with no existing autoidentifications
handles.already_autoidentified = ...
    zeros(num_bins, num_samples);

% If there is no predefined peaks structure, start with no detected 
% peaks (but preallocate the array)
if ~isfield(handles, 'peaks')
    handles.peaks = cell(1,num_samples);
    for s=1:handles.collection.num_samples
        handles.peaks{s}='Uninitialized';
    end
end

% Start with constant model with no pentalties as the default for each 
% bin/spectrum combination
handles.models(num_bins, num_samples)=RegionalSpectrumModel('constant', 0, 0, 0.0086, 0.004);
for b=1:num_bins
    for s=1:num_samples
        handles.models(b, s)=RegionalSpectrumModel('constant', 0, 0, 0.0086, 0.004);
    end
end

% Start with deconvolutions as a matrix of empty CachedValue
% objects
handles.deconvolutions(num_bins, num_samples) = CachedValue;
for b=1:num_bins
    for s=1:num_samples
        handles.deconvolutions(b,s)=CachedValue;
    end
end

% Start with no tool selected

% Start at the first bin and spectrum
handles.spectrum_idx = 1;
handles.bin_idx = 1;

% Autoidentify the first bin and spectrum
handles = potentially_autoidentify(handles);

out_handles = handles;

function uname = get_username
%GET_USERNAME returns the current username (gets from user if not in prefs)
% Checks the preferences for the current username, and if found returns it.
% Otherise puts up a dialog asking the user and then stores the name in the
% preferences.
if ispref('Targeted_Deconvolution_ID','username')
    uname = getpref('Targeted_Deconvolution_ID','username');
else
    uname = [];
    while isempty(uname)
        uname = inputdlg({['Enter your full name - to give credit for peak ',...
            'identifications']},'Enter user name');
        if ~isempty(uname)
            uname = uname{1};
        end
    end
    setpref('Targeted_Deconvolution_ID','username', uname);
end

function account_id = get_account_id
%GET_account_ID returns a uuid for this account
% Checks the preferences for a previously set uuid.  If not, uses
% random_uuid to generate a new one and saves it in the preferences
if ispref('Targeted_Deconvolution_ID','account_id')
    account_id = getpref('Targeted_Deconvolution_ID','account_id');
else
    account_id = random_uuid;
    setpref('Targeted_Deconvolution_ID', 'account_id', account_id);
end


% --- Executes just before targeted_identify is made visible.
function targeted_identify_OpeningFcn(hObject, unused, handles, varargin) %#ok<INUSL>
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to targeted_identify (see VARARGIN)

% Choose default command line output for targeted_identify
handles.output = hObject;

% Initialize the gui and handles structure using data passed in from
% targeted_deconv_start
if isappdata(0,'collection') && isappdata(0,'metab_map')
    % Move the app data from the matlab root into handle variables
    handles.collection = getappdata(0,'collection');
    handles.metab_map = getappdata(0,'metab_map');

    % Remove app data from matlab root so it is not sitting around
    rmappdata(0, 'collection');
    rmappdata(0, 'metab_map');

    % If there is peak app data, set it up too, then remove it
    if isappdata(0, 'peaks')
        handles.peaks = getappdata(0, 'peaks');
        rmappdata(0, 'peaks');
    end
    
    % Initialize everything else from scratch
    handles = init_handles_and_gui_from_scratch(handles);
    
elseif isappdata(0,'saved_session_data')
    session_data = getappdata(0,'saved_session_data');
    handles = init_handles_and_gui_from_session_data(handles, session_data);
    
    %Remove app data from matlab root so it is not sitting around
    rmappdata(0,'saved_session_data');
else
    uiwait(msgbox('Either the metab_map or collections were not loaded.','Error','error','modal'));
    handles.collection = bogus_collection;
    handles.metab_map =CompoundBin(CompoundBin.csv_file_header_string, ...
        '3,"",4,"hippurate","X",7.857000,7.815000,"d",2,"","CH2, CH6",714,"X","Chemonx/Lindon/Measured","1H","Multiplicity is different in HMDB"');
    
    handles = init_handles_and_gui_from_scratch(handles);
end

% Confirmation check is always zero in all cases
handles.did_expected_peaks_confirmation_check = 0;


% Set the automatic zoom
handles.auto_y_zoom = true; %True if should automatically reset the y axis' zoom to fit the window contents whenever the x axis' changes


% Initialize the display components
update_display(handles);
zoom_to_bin(handles);
update_plot(handles);
zoom_to_bin(handles);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes targeted_identify wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% ------------------------------------------------------------------------
%
% Misc
%
% ------------------------------------------------------------------------

function y = y_values_in_cur_bin(handles)
% Return the y values that fall within the current bin (choosing the
% indices of the bin boundaries to be the closest x values to the bin
% boundaries)
bin_idx = handles.bin_idx;
spectrum_idx = handles.spectrum_idx;
bin = handles.metab_map(bin_idx).bin;
low_idx = index_of_nearest_x_to(bin.left, handles);
high_idx = index_of_nearest_x_to(bin.right, handles);
if low_idx > high_idx
    t = low_idx; 
    low_idx = high_idx;
    high_idx = t;
end
y = handles.collection.Y(low_idx:high_idx, spectrum_idx);

function name=unique_name(base, extension)
% Return a unique filename in the current directory using base and
% extension.  The name returned will be of the form base_xxxxxx.extension.
%
% Note: there is a race condition between checking for the existence of the
% file name and the name being used.  The file may be created some-time
% between that.
for i=0:999999
    name=sprintf('%s_%06d.%s',base,i,extension);
    if ~exist(name, 'file')
        return
    end
end

function ret=am_connected_to_internet
% Returns true if can access certain www sites, false otherwise
[unused, success] = urlread('http://www.google.com/'); %#ok<ASGLU>
ret = success;

function draw_circle(center, radius_inches, color) %#ok<DEFNU>
% Draws a circle on the current axes at the center location (in data 
% coordinates).  The radius of the circle drawn is in inches.
%
% center        The center of the circle to draw (in data coordinates).
%               Pass as [x y]
% radius_inches The radius of the circle as plotted on the screen in inches
% color         The color of the circle to plot
%
% It is OK that this function is unused - it is a useful utility function
% that I don't want to forget having written.
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


% --- Outputs from this function are returned to the command line.
function varargout = targeted_identify_OutputFcn(unused2, unused, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function new_val=substitute(old_val, from, to)
% Substitutes to(i) for every occurrence of from(i) in old_val
%
% Working from low to high i, first replaces every occurrence of from(1)
% with to(1), then, in the new array, every occurrence of from(2) with
% to(2).  Until it runs out of from values.  From and to must be the same
% size.
%
% old_value  The original value of the array in which the substitution
%            takes placs
% 
% from       The values to be replaced in old_value
%
% to         to(i) is the value with which to replace from(i)
%
%
%
% new_val    old_val after the replacements have been made

if length(from) ~= length(to)
    error('targeted_identify__substitute:not_same_size','"From" and "to" arrays must be the same size in substitue');
end
new_val = old_val;
for i=1:length(from)
    matches = new_val == from(i);
    new_val(matches) = to(i);
end


% ------------------------------------------------------------------------
%
% Peaks
%
% ------------------------------------------------------------------------

function pks = get_spectrum_peaks(handles, spectrum_idx)
% Return the peaks for the current spectrum (or the argument).  
%
% Either uses those peaks already calculated and/or modified by the user 
% or (if they haven't been calculated yet) calculates them.  Does not 
% update the GUI if the peaks are calculated.  But does update the 
% guidata for handles.figure1
%
% handles       The global handles structure.  If spectrum_idx is not 
%               passed as an argument, sets it from handles.spectrum_idx
%
% spectrum_idx  The index of the spectrum whose peaks should be returned.
%               Optional argument.
if nargin < 2
    spectrum_idx = handles.spectrum_idx;
end
pks = handles.peaks{spectrum_idx};
%Calculate the peaks
if ischar(pks) && strcmp(pks,'Uninitialized')
    % I've tried to put a waitbar in here, but something about the way
    % matlab allocates handles and the use of global variables elsewhere
    % (gca in the plotting routines) causes problems - the guidata doesn't
    % get set properly, and, if I don't close the waitbar, the plot gets
    % drawn on the waitbar. I decided adding the waitbar wasn't worth the 
    % but that I should add this note to outline the problems I found for
    % future maintainers who might want to add a waitbar.
    col = handles.collection;
    noise_points = 30; % use 1st 30 pts to estimate noise standard deviation
    %If there are too few points, use them all as noise
    ysize = size(col.Y);
    if noise_points > ysize(1)
        noise_points = ysize(1);
    end
    noise_std = std(col.Y(1:noise_points, spectrum_idx));
    [peak_idx, unused, unused] = wavelet_find_maxes_and_mins ...
        (col.Y(:,spectrum_idx), noise_std); %#ok<NASGU,ASGLU>
    pks = col.x(peak_idx);
    handles.peaks{spectrum_idx} = pks;
    guidata(handles.figure1, handles);
end

function pks = get_spectrum_and_bin_peaks(handles, bin_idx, spectrum_idx)
% Return the peaks in the current bin and current spectrum or those passed as arguments.  
%
% Uses get_spectrum_peaks so may initialize peaks changing the value for
% guidata(handles.figure1).  Does not update the GUI.
%
% handles       The global handles structure.  If spectrum_idx is not 
%               passed as an argument, sets it from handles.spectrum_idx.
%               bin_idx is treated similarly but init'd from
%               handles.bin_idx
%
% spectrum_idx  The index of the spectrum whose peaks should be returned.
%               Optional argument.  If absent, uses current spectrum from
%               handles.
%
% bin_idx       The index of the bin in handles.metab_map into which returned
%               peaks must fall.  Optional argument.  If absent, uses the
%               current bin from handles.
if nargin >= 3
    pks = get_spectrum_peaks(handles, spectrum_idx);
else
    pks = get_spectrum_peaks(handles);
end
if nargin <= 1
    bin_idx = handles.bin_idx;
end
bin = handles.metab_map(bin_idx).bin;
pks = pks(pks <= bin.left & pks >= bin.right);

function indices = bins_invalidated_by_peak_change(metab_map, old_x, new_x)
% Indices of bins whose extant deconvolution is invalidated by changing the list of peaks in old_x to that in new_x
%
% If any peaks change (are added or removed) in the range covered by a bin 
% then the bin is invalidated by the change.
%
% metab_map The list of bins
% old_x   The list of peak locations prior to the change
% new_x   The list of peak locations subsequent to the change
changed_x = setxor(old_x, new_x);
changed_bin = zeros(1,length(metab_map));
for i=1:length(metab_map)
    changed_bin(i)=any((metab_map(i).bin.left >= changed_x) & ...
        (metab_map(i).bin.right <= changed_x));
end
indices = find(changed_bin);

function handles=set_spectrum_peaks_no_gui(spectrum_idx, new_val, handles)
% Just like set_spectrum_peaks but does not update the gui (note that you
% will need to update both the plot and display after calling this routine)
changed_indices = bins_invalidated_by_peak_change(handles.metab_map, ...
    get_spectrum_peaks(handles, spectrum_idx), new_val);
if ~isempty(changed_indices)
    for bin_idx = changed_indices
        handles.deconvolutions(bin_idx, spectrum_idx).invalidate;
    end
end
handles.peaks{spectrum_idx} = new_val;
guidata(handles.figure1, handles);


function handles=set_spectrum_peaks(spectrum_idx, new_val, handles)
% Set the peaks for the given spectrum.  Updates deconvolution 
% valid states and the guidata stored in handles.figure1.  Updates the gui. 
% Returns the new value of handles
%
% spectrum_idx  The index of the spectrum in the current collection where
%               the peaks lie
% new_val       The new value to use for the peaks
% handles       The user and GUI data structure
handles = set_spectrum_peaks_no_gui(spectrum_idx, new_val, handles);
update_plot(handles);
update_display(handles);

function add_peak(ppm, handles)
% Adds a peak to the list of peaks for the spectrum (if the
% ppm is not already marked as having a peak)
%
% ppm      parts per million location of the new peak
% handles  The user and GUI data structure
pks = get_spectrum_peaks(handles);
matches = pks == ppm;
if ~any(matches)
    spectrum_idx = handles.spectrum_idx;
 
    set_spectrum_peaks(spectrum_idx, sort([pks, ppm]), handles);
end

function remove_peak(ppm, handles)
% Removes a peak at the given ppm from the list of peaks for the 
% current spectrum.  If there is no such peak, does nothing.  If
% there is an identification for the current metabolite at that ppm, also 
% removes the identification.
%
% ppm      parts per million location of the peak to remove
% handles  The user and GUI data structure
pks = get_spectrum_peaks(handles);
matches = pks==ppm;
if any(matches)
    remove_identification(ppm, handles);
    handles = guidata(handles.figure1);

    pks(matches)=[];
    
    spectrum_idx = handles.spectrum_idx;
    set_spectrum_peaks(spectrum_idx, pks, handles);
end


% ------------------------------------------------------------------------
%
% Identifications
%
% ------------------------------------------------------------------------

function ids = peak_identifications_for(bin_idx, spec_idx, handles)
% Return the list of the peak identification objests for the given
% metabolite bin and spectrum
%
% bin_idx  The index of the metabolite bin in the metab_map
%
% spec_idx The index of the spectrum in the collection
idents = handles.identifications;
if(isempty(idents))
    ids = [];
else
    bins = [idents.compound_bin];
    correct_bin = [bins.id]==handles.metab_map(bin_idx).id;
    specs = [idents.spectrum_index];
    correct_spec = specs == spec_idx;
    ids = idents(correct_bin & correct_spec);
end


function ids=cur_peak_identifications(handles)
% Return the list of the peak identification objests for the current 
% metabolite and spectrum
ids = peak_identifications_for(handles.bin_idx, handles.spectrum_idx, handles);

function handles = update_peak_identifications_for(bin_idx, spec_idx, ...
    old_ppms, new_ppms, handles)
% Translate ppms for identifications
%
% Change any identifications for the bin & spectrum that have a ppm closest
% to old_ppms(i) to have a ppm equal to new_ppms(i).  Return the modified
% handles structure.
idents = handles.identifications;
if(isempty(idents))
    id_indices = [];
else
    bins = [idents.compound_bin];
    correct_bin = [bins.id]==handles.metab_map(bin_idx).id;
    specs = [idents.spectrum_index];
    correct_spec = specs == spec_idx;
    id_indices = find(correct_bin & correct_spec);
end

for id_idx = id_indices
    id = idents(id_idx);
    diffs = abs(id.ppm - old_ppms);
    nearest_ppm_idx = min_idx(diffs);
    idents(id_idx).ppm = new_ppms(nearest_ppm_idx);
end

handles = set_identifications(idents, handles);


function num=cur_num_identified(handles)
% Return the number of identified peaks for current metabolite and spectrum
num = length(cur_peak_identifications(handles));

function remove_identification(ppm, handles)
% Removes the identification at the given ppm - if there is no
% identification there, does nothing
ids = cur_peak_identifications(handles);
if ~isempty(ids)
    id_x = [ids.ppm];
    to_remove = ids(id_x == ppm);
    if ~isempty(to_remove)
        new_ids = handles.identifications;
        for id_to_remove=to_remove %Remove each ident'n one at a time
            new_ids(new_ids == id_to_remove) = [];
        end
        set_identifications(new_ids, handles);
    end
end
    
function handles = set_identifications(new_identifications, handles)
handles.identifications = new_identifications;
guidata(handles.figure1, handles);
update_display(handles);
update_plot(handles);

function result=is_identified(ppm, handles)
% Returns true if there is an identification at the given ppm, false
% otherwise
%
% ppm     The ppm at which to check the existence of an identification
% handles The gui global data structure
ids = cur_peak_identifications(handles);
if isempty(ids)
    result = 0;
    return;
else
    id_x = [ids.ppm];
    result = any(id_x == ppm);
    return;
end

function new_handles = potentially_autoidentify(handles)
% Autoidentifies peaks if no identifications are
% extant for the current bin and spectrum, and the current spectrum has the 
% same number of peaks as would be expected.  Returns the new value of the 
% handles structure.  Also sets the guidata.

%If no autoidentification has been done on this bin
if ~handles.already_autoidentified(handles.bin_idx, handles.spectrum_idx)
    %If no current identifications
    ids = cur_peak_identifications(handles);
    if isempty(ids)
        %If correct number of peaks
        bin = handles.metab_map(handles.bin_idx);
        pks = get_spectrum_and_bin_peaks(handles);
        if length(pks) == bin.num_peaks
            % Do autoidentification:

            %First mark as identified
            handles.already_autoidentified(handles.bin_idx, ...
                handles.spectrum_idx) = 1;

            %Then make identification objects for all peaks in the bin
            new_ids(bin.num_peaks)=PeakIdentification;
            for i = 1:bin.num_peaks
                ppm = pks(i);
                xidx = index_of_nearest_x_to(ppm, handles);
                new_ids(i) = PeakIdentification(ppm, xidx, ...
                    handles.spectrum_idx, bin, ...
                    1, get_username, get_account_id, datestr(clock)); 
            end

            %Finally add them to the identifications for the gui
            set_identifications([handles.identifications new_ids], handles);
            handles = guidata(handles.figure1);
        end
        
    end
end
new_handles = handles;

% ------------------------------------------------------------------------
%
% Plotting and Display
%
% ------------------------------------------------------------------------

function update_plot(handles)
% Update the plot - needed when the spectrum index changes, the
% identifications change, the deconvolution display state changes, or the
% current deconvolution is updated

%Save the current figure and update only the plot on the targeted_identify
%figure
old_figure = get(0,'CurrentFigure');
set(0,'CurrentFigure', handles.figure1);

if ishold
    hold off;
end
oldlims = xlim;
plot(handles.collection.x,handles.collection.Y(:,handles.spectrum_idx));
set(gca,'xdir','reverse');
if ~ (oldlims(1) == 0 && oldlims(2) == 1)
    xlim(oldlims)
end

%Draw deconvolution
if get(handles.should_show_deconv_box,'Value')
    hold on;
    cv = handles.deconvolutions(handles.bin_idx, handles.spectrum_idx);
    if cv.exists
        deconv = cv.value;
        fit_x = handles.collection.x(deconv.fit_indices);
        plot(fit_x, deconv.y_baseline, 'Color', 'y');    %Yellow baseline
        plot(fit_x, deconv.y_fitted,'Color',[.5,.5,.5]); %Gray fitted
        for pk = deconv.peaks
            plot(fit_x, pk.at(fit_x),'Color','m'); %Magenta peaks
        end
    end
end

%Draw peak location lines
ids = cur_peak_identifications(handles);
cur_y = y_values_in_cur_bin(handles);
y_bounds = [min(cur_y), max(cur_y)];
if isempty(ids)
    id_ppms = [];
else
    id_ppms = [ids.ppm];
end
for ppm = get_spectrum_peaks(handles)
    if any(id_ppms==ppm)
        line_color = 'r';
    else
        line_color = 'c';
    end
    line('XData', [ppm,ppm], 'YData', y_bounds, 'Color', line_color);
end

%Reset the button-down function on the generated plot
set(gca,'ButtonDownFcn',@spectrum_plot_ButtonDownFcn);

%Make the child-objects non-clickable so that all clicks are on the axes
%object
children = get(gca,'Children');
for child_handle=children
    set(child_handle, 'HitTest', 'off');
end

%Restore the current figure to its initial value
set(0,'CurrentFigure', old_figure);

function update_display(handles)
% Updates the various UI objects to reflect the state saved in the handles
% structure.  Needed when the spectrum index, the bin index, or the
% identifications list changes.  Also needed when the display deconvolution
% state changes or the current deconvolution is updated.
%
% handles The handles structure containing the GUI application state
set(handles.metabolite_menu, 'Value', handles.bin_idx);
cur_bin=handles.metab_map(handles.bin_idx);
set(handles.multiplicity_text,'String', strcat('Multiplicity: ', ...
    cur_bin.readable_multiplicity));
set(handles.nucleus_assignment_text,'String',strcat('Nucleus: ', ...
    cur_bin.nucleus_assignment));
set(handles.literature_text,'String',strcat('Literature: ', ...
    cur_bin.literature));
set(handles.num_expected_peaks_text,'String', ...
    sprintf('Expected peaks: %d', cur_bin.num_peaks));
set(handles.spectrum_number_edit_box,'String', ...
    sprintf('%d', handles.spectrum_idx));
set(handles.num_identified_peaks_text,'String', ...
    sprintf('Identified peaks: %d', ...
    cur_num_identified(handles)));

% Set the baseline_menu to the correct entry
model = handles.models(handles.bin_idx, handles.spectrum_idx);
switch model.baseline_type
    case 'spline'
        value_idx = 1;
    case 'line_up'
        value_idx = 3;
    case 'line_down'
        value_idx = 4;
    case 'constant'
        value_idx = 5;
    case 'v'
        value_idx = 2;
    otherwise
        error('targeted_identify:bad_line_type', ...
            ['Unknown line type "%s" in spectrum model for ' ...
            'bin: %d spectrum: %d'], line_type, cur_bin, ...
            handles.spectrum_idx);
end
set(handles.baseline_menu, 'Value', value_idx);

% Set the regularization boxes
set(handles.baseline_area_penalty_edit_box, 'String', ...
    num2str(model.baseline_area_penalty,5));
set(handles.width_variance_penalty_edit_box, 'String', ...
    num2str(model.linewidth_variation_penalty,5));

% Set the rough deconvolution boxes
set(handles.rough_peak_window_ppm_edit, 'String', ...
    num2str(model.rough_peak_window_width,6));
set(handles.rough_peak_max_width_edit, 'String', ...
    num2str(model.max_rough_peak_width,6));

% Show or hide update deconvolution button depending on whether the current
% deconvolution is updated
if get(handles.should_show_deconv_box,'Value')
    set(handles.update_deconv_button, 'Visible', 'on');
    deconv = handles.deconvolutions(handles.bin_idx, handles.spectrum_idx);
    if deconv.is_updated
        set(handles.update_deconv_button, 'String', 'Update Deconv');    
    else
        set(handles.update_deconv_button, 'String', 'Update Deconv*');
    end
else
    set(handles.update_deconv_button, 'Visible', 'off');
end

bin_idx = handles.bin_idx;
num_bins = length(handles.metab_map);
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

function zoom_to_box(right, left, bottom, top)
% Set the plot boundaries to the interval [right, left] [bottom, top]
%
%
% Usage:
%
% zoom_to_box(right, left, bottom, top)
%
% zoom_to_box(right, left, 'auto')
%
% If called with only 3 arguments, sets the vertical plot interval
% automatically.
%
% right, left --- [min, max] for x
%
% bottom, top --- [min, max] for y
xlim([right, left]);
if nargin > 3
    ylim([bottom, top]);
else
    ylim('auto');
end


function [minim,maxim]=zoom_interval(zoom_factor, old_minim, old_maxim)
% Zoom the given interval around the center by the given factor
%
% Input arguments:
%
% zoom_factor: the width of the interval will be multiplied by 
%              the given factor
%
% old_minim:   the minimum of the old interval
%
% old_maxim:   the maximum of the old interval
%
% Return values:
%
% [minim,maxim] = minimum and maximum of the new zoomed interval
%
half_width = (old_maxim - old_minim) / 2;
center = (old_maxim + old_minim) / 2;
new_half_width = zoom_factor * half_width;
minim = center - new_half_width;
maxim = center + new_half_width;


function zoom_plot(zoom_factor, should_zoom_x, handles)
% Zoom the spectrum_plot by multiplying the viewing interval width by zoom 
% factor, expanding or contracting it around its current center
% 
% If should_zoom_x is false, then the zoom is not done on the x axis

cur_x_interval = xlim(handles.spectrum_plot);
[xmin,xmax] = zoom_interval(zoom_factor, cur_x_interval(1), cur_x_interval(2));

cur_y_interval = ylim(handles.spectrum_plot);
[ymin,ymax] = zoom_interval(zoom_factor, cur_y_interval(1), cur_y_interval(2));

if    ~handles.auto_y_zoom && should_zoom_x
    zoom_to_box(xmin, xmax, ymin, ymax);
elseif handles.auto_y_zoom && should_zoom_x
    zoom_to_box(xmin, xmax, 'auto');
elseif handles.auto_y_zoom && ~should_zoom_x
    zoom_to_box(cur_x_interval(1), cur_x_interval(2), 'auto');
else %~handles.auto_y_zoom && ~should_zoom_x
    zoom_to_box(cur_x_interval(1), cur_x_interval(2), ymin, ymax);
end

function zoom_to_bin(handles)
% Set the plot boundaries to the current bin boundaries.  Needed when bin
% index changes (and at other times)
cb=handles.metab_map(handles.bin_idx);
zoom_to_box(cb.bin.right, cb.bin.left, 'auto');
handles.auto_y_zoom = true;
guidata(handles.figure1, handles);

% ------------------------------------------------------------------------
%
% Spectrum idx and Bin idx
%
% ------------------------------------------------------------------------

function set_spectrum_and_bin_idx(new_spec, new_bin, handles)
% Sets handles.spectrum_idx and handles.bin_idx and also updates the gui 
% I believe (though I haven't verified) that the value in handles in the 
% caller will be unchanged.
handles = warn_if_no_confirmation_check(handles);
handles.spectrum_idx = new_spec;
handles.bin_idx = new_bin;
handles = potentially_autoidentify(handles);
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
handles = warn_if_no_confirmation_check(handles);
handles.spectrum_idx = new_val;
handles = potentially_autoidentify(handles);
guidata(handles.figure1, handles);
update_display(handles);
update_plot(handles);

function set_bin_idx(new_val, handles)
% Sets handles.bin_idx and also updates the gui - don't call when you
% update the spectrum_idx to avoid repeating updates.  I believe (though I
% haven't verified) that the value in handles in the caller will be
% unchanged.
%
% new_val   the new value of the bin_idx
% handles   structures with handles and user data
handles = warn_if_no_confirmation_check(handles);
handles.bin_idx = new_val;
handles = potentially_autoidentify(handles);
guidata(handles.figure1, handles);
update_display(handles);
zoom_to_bin(handles);
update_plot(handles);
zoom_to_bin(handles);

function [change_is_ok, new_handles] = changing_spectrum_or_bin_is_ok(handles)
% Confirms that changing spectrum_idx or bin_idx is ok with the user.
%
% In the case where the user might not want to change the spectrum or bin
% due to not having identified the correct number of peaks, pops up a
% warning and returns the user's response.  Otherwise just says the 
% change is ok.  In all cases modifies handles to 
% set new_handles.did_expected_peaks_confirmation_check to true so that
% subsequent calls to set_spectrum_idx and friends will not display an
% error message.  Also changes guidata for handles.figure1 to new_handles.
%
% Callers should call this as:
%
% [change_is_ok, handles] = changing_spectrum_or_bin_is_ok(handles);
%
% To keep an updated copy of the handles structure;
bin_idx = handles.bin_idx;
new_handles = handles;
new_handles.did_expected_peaks_confirmation_check = 1;
guidata(handles.figure1, new_handles);
change_is_ok = 1;

%Warn if the number of identified peaks is not what is expected
num_ident = cur_num_identified(handles);
bin = handles.metab_map(bin_idx);
if bin.num_peaks ~= num_ident
    response = questdlg([bin.readable_multiplicity, ' should have ', ...
        sprintf('%d',bin.num_peaks), ...
        ' peaks, but you have identified ', sprintf('%d', num_ident), ...
        ' peaks.  Would you like to fix this or ignore it?'], ...
        'Unexpected number of identifications', ...
        'Fix peak identifications', 'Leave identifications as they are',...
        'Fix peak identifications');
    if strcmp(response,'Fix peak identifications')
        change_is_ok = 0;
        return;
    end
end

function new_handles = warn_if_no_confirmation_check(handles)
% Makes a warning dialog and sends an email to developers if there the
% confirmation check has not been called.  Return handles with confirmation
% check turned off again.
%
% This check was written because many paths can cause the changing of a bin
% or spectrum index and all of them should have a confirmation message
% displayed if the number of identified peaks is not the expected.  This
% function detects if the program got to a spectrum/bin idx changing
% routine without first executing a confirmation check.

if ~(handles.did_expected_peaks_confirmation_check)

    %Generate error message and send it to the developers
    [stack_trace, unused]=dbstack('-completenames'); %#ok<NASGU>
    error_message{3+4*length(stack_trace)}='';
    error_message{1} = ['No check to see if a confirmation dialog was '...
        'needed was performed before changing spectrum_idx or bin_idx'];
    error_message{2} = 'Stack trace follows:';
    error_message{3} = '';
    for i = 1:length(stack_trace)
        frame = stack_trace(i);
        error_message{3+4*i-3} = '';
        error_message{3+4*i-2} = ['File: ' frame.file];
        error_message{3+4*i-1} = sprintf('Line: %d', frame.line);
        error_message{3+4*i-0} = ['Function name: ' frame.name];
    end

    send_email_from_birg_autobug('eric_moyer@yahoo.com', ...
        'No confirmation check done in targeted deconvolution', ...
        error_message);

    % Display a message so things are caught during debugging
    msgbox(['You can safely ignore this dialog box.  It is a debugging '...
        'tool for programmers.  Just click ok.  We are sorry for the '...
        'inconvenience.  It will be fixed in the next version.'], ...
        'Ignore this dialog box', 'modal');
end

% Reset the confirmation check flag
new_handles = handles;
new_handles.did_expected_peaks_confirmation_check = 0;

% ------------------------------------------------------------------------
%
% Conversion from x values to indices of various arrays
%
% ------------------------------------------------------------------------

function idx = min_idx(vals)
min_val = min(vals);
idx = find(vals == min_val, 1, 'first');

function idx = index_of_nearest_point_to(target, points_x, points_y) %#ok<DEFNU>
% Return the index of the point closest to target in the points described
% by points_x and points_y
%
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

function idx = index_of_nearest_peak_to(val, handles)
% Return the index of the value closest to val in the x coordinates of the 
% peaks for this spectrum or 0 if there are no peaks
%
% handles structure with handles and user data (see GUIDATA)
pks = get_spectrum_peaks(handles);
if isempty(pks)
    idx = 0;
    return;
else
    diffs = abs(val - pks);
    idx = min_idx(diffs);
    return;
end


% ------------------------------------------------------------------------
%
% UI Callbacks
%
% ------------------------------------------------------------------------

function spectrum_number_edit_box_Callback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to spectrum_number_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spectrum_number_edit_box as text
%        str2double(get(hObject,'String')) returns contents of spectrum_number_edit_box as a double
entry  = str2double(get(hObject,'String'));
if ~isnan(entry) %If the user typed a number
    entry = round(entry);
    if (entry >= 1) && (entry <= handles.collection.num_samples)
        [change_is_ok, handles] = changing_spectrum_or_bin_is_ok(handles);
        if change_is_ok
            set_spectrum_idx(entry, handles);
        else
            %Set the edit box back to the number of the current spectrum
            set(hObject, 'String', sprintf('%d', handles.spectrum_idx));
        end
    else
        uiwait(msgbox( ...
            sprintf('Invalid spectrum number.  There are only %d spectra.', ...
                handles.collection.num_samples), 'Error','error','modal'));
    end
end

% --- Executes on button press in previous_button.
function previous_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to previous_button (see GCBO) - this is the first argument 
%            (that is now replaced by ~) 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[change_is_ok, handles] = changing_spectrum_or_bin_is_ok(handles);
if ~change_is_ok
    return;
end

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
function next_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bin_idx = handles.bin_idx;
spec_idx = handles.spectrum_idx;
num_spec = handles.collection.num_samples;

%Get confirmation from the user in situations where it might not be good to
%change the bin or spectrum. Do nothing if not ok to change.
[change_is_ok, handles] = changing_spectrum_or_bin_is_ok(handles);
if ~change_is_ok
    return;
end

%Go to the next compund
if spec_idx < num_spec
    %Same compound
    set_spectrum_idx(spec_idx+1, handles);
else 
    %Next compound
    num_bins = length(handles.metab_map);
    if bin_idx < num_bins
        set_spectrum_and_bin_idx(1, bin_idx+1, handles);
        uiwait(msgbox('Changing to next compound', ...
            'Changing to next compound','modal'));
    else
        uiwait(msgbox('Please enter a file to save the identified peaks to', ...
            'Select identified file','modal'));
        
        id_name = 0; 
        while(id_name == 0)
            [id_name,id_path] = uiputfile('*.txt', ...
            'Select file for the identified peaks');
        end
        
        uiwait(msgbox('Now a enter a file for the residual data', ...
            'Select identified file','modal'));
        
        resid_name = 0; 
        while(resid_name == 0)
            [resid_name,resid_path] = uiputfile('*.txt', ...
            'Select file for the residual data');
            if strcmp(resid_name, id_name) && strcmp(resid_path, id_path)
                resid_name = 0;
                uiwait(msgbox('You cannot use the same file for both the identified peaks and residual data', ...
                    'Error','error','modal'));
            end
        end
        
        excel_compat_name = 0; 
        while(excel_compat_name == 0)
            [excel_compat_name,excel_compat_path] = uiputfile('*.csv', ...
                'Select file for the excel compatible deconvolved data');
            fullexcelname = fullfile(excel_compat_path,excel_compat_name);
            if strcmp(fullexcelname, fullfile(id_path, id_name)) || ...
               strcmp(fullexcelname, fullfile(resid_path, resid_name))
                excel_compat_name = 0;
                uiwait(msgbox('You cannot resuse a file name.  Please choose a different name', ...
                    'Error','error','modal'));
            end
            clear('fullexcelname');
        end
        
        fraction_done = 0;
        wait_bar_handle = waitbar(fraction_done,['Final processing: ' ...
            'Compressing identifications']);
        
        %Send the labeled spectral data to eric
        pkid_name=unique_name(...
            fullfile(id_path,'please email to eric_moyer_at_yahoo.com'),...
            'mat');
        zip_name = [pkid_name '.zip'];
        collection = handles.collection; %#ok<NASGU>
        metab_map = handles.metab_map; %#ok<NASGU>
        peaks = handles.peaks; %#ok<NASGU>
        identifications = handles.identifications; %#ok<NASGU>
        save(pkid_name, 'collection','metab_map','peaks','identifications');
        zip(zip_name, pkid_name);
        delete(pkid_name);
        clear('collection','metab_map','peaks','identifications');
        
        
        if ~exist('./dont_send_emails.foobarbaz','file')
            % Send the email
            fraction_done = 0.1;
            waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
                'Sending identifications to BIRG']);
            if am_connected_to_internet
                dir_info = dir(zip_name);
                if dir_info.bytes < 20*1024*1024 %20 MB attachment limit
                    send_email_from_birg_autobug('eric_moyer@yahoo.com', ...
                        ['Spectrum Identifications from ' get_username ' on ' ...
                        datestr(clock)], ...
                        'The identifications are in the attachment', ...
                        {zip_name} ...
                    );
                    delete(zip_name);
                else
                    uiwait(msgbox(['Could not automatically send large data file.  ', ...
                        'Please e-mail the file "' zip_name ...
                        '" to eric_moyer@yahoo.com.  Thank you.']));
                end
            else
                uiwait(msgbox(['You are not connected to the Internet.  ', ...
                    'Please e-mail the file "' zip_name ...
                    '" to eric_moyer@yahoo.com.  Thank you.']));
            end
        end
        
        % -----------------------------------------------------------------
        % Finish any pending deconvolutions and store the data
        % -----------------------------------------------------------------
        
        fraction_done = 0.15;
        waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
            'Initializing collections']);
        
        dec = handles.collection; %deconvolved
        res = handles.collection; %residual
        num_spec = dec.num_samples;
        
        % Create new processing messages
        num_bins = length(handles.metab_map);
        
        bin_names = '';
        for bin_idx = 1:num_bins
            cur_bin = handles.metab_map(bin_idx);
            if bin_idx == num_bins
                separator = '';
            else
                separator = ',';
            end
            bin_names=sprintf('%s %s (%d)%s', ...
                bin_names, cur_bin.compound_name, cur_bin.id, separator);
        end
        dec.processing_log = [dec.processing_log, '  Extracted peak ', ...
            'areas for: ', bin_names, '.'];
        res.processing_log = [res.processing_log, '  Extracted ', ...
            'residual after subtracting peaks for: ', bin_names, '.'];
        
        % Create x-values for deconvolved collection
        num_x = 0;
        for b = handles.metab_map;
            num_x = num_x + b.num_peaks + 1;
        end
        dec.x = zeros(1,num_x);
        dec.Y = zeros(num_x, num_spec);
        clear('b','num_x');
        
        x_idx = 1;
        for bin = handles.metab_map;
            dec.x(x_idx) = bin.id * 1000;
            for i = 1:bin.num_peaks
                dec.x(x_idx + i) = bin.id * 1000 + i;
            end
            x_idx = x_idx + bin.num_peaks + 1;
        end
        
        fraction_done = 0.16;
        waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
            'Updating deconvolutions']);
        
        n_bin_spec = num_bins * num_spec;
        bin_spec_completed = 0;
        
        % Create the y-values for the deconvolved collection
        identified_peaks = cell(num_bins, num_spec); %save the peaks for the residual calculation
        for spec_idx = 1:num_spec
            block_idx = 1; %Index of start of next block of y values to fill
            for bin_idx = 1:num_bins
                % Calculate the areas under the deconvolved, identified
                % peaks
                
                % Update the deconvolutions and initialized the
                % identified_peaks entry
                if ~handles.deconvolutions(bin_idx, spec_idx).is_updated
                    handles = recalculate_deconv(bin_idx, spec_idx, handles);
                end
                %TODO: don't move the peak locations, instead just do
                %the alignment and store some sort of translation table
                %for later finding the identified peaks
                handles = align_peaks_with_deconv(bin_idx, spec_idx, handles);
                
                d = handles.deconvolutions(bin_idx, spec_idx).value;
                idents = peak_identifications_for(bin_idx, ...
                    spec_idx, handles);
                if isempty(idents)
                    identified_peaks{bin_idx, spec_idx} = [];
                else
                    identified_peaks{bin_idx, spec_idx}(length(idents)) = ...
                        GaussLorentzPeak;
                end
                
                % Fill in the areas array, leaving 0's where a peak was not
                % identified
                bin = handles.metab_map(bin_idx);
                num_peaks = bin.num_peaks;
                areas = zeros(1, num_peaks);
                                
                for i = 1:length(idents)
                    p = d.peak_at(idents(i).ppm);
                    identified_peaks{bin_idx, spec_idx}(i) = p;
                    areas(i) = p.area;
                end
                
                % Fill in the y values using the areas
                dec.Y(block_idx, spec_idx) = sum(areas);
                for i = 1:length(areas)
                    dec.Y(block_idx + i, spec_idx) = areas(i);
                end
                
                % Advance to next bin, updating the waitbar
                block_idx = block_idx + bin.num_peaks + 1;
                bin_spec_completed = bin_spec_completed + 1;
                fd = fraction_done + (0.64*bin_spec_completed / n_bin_spec);
                msg = sprintf(['Final ' ...
                    'processing: Updating deconvolutions ... %d of %d'], ...
                    bin_spec_completed, n_bin_spec); %Unused for now
                waitbar( fd, wait_bar_handle, msg );
            end
        end
        
        fraction_done = 0.80;
        waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
            'Calculating residuals']);
        bin_spec_completed = 0;
        
        % Subtract the deconvolved peaks from the current y values of the
        % residual
        for spec_idx = 1:num_spec
            peak_sum = zeros(length(res.x),1);
            for bin_idx = 1:num_bins
                ip = identified_peaks{bin_idx, spec_idx};
                if ~isempty(ip)
                    for p = ip
                        peak_sum = peak_sum + p.at(res.x)';
                    end
                end
                bin_spec_completed = bin_spec_completed + 1;
            end
            res.Y(:, spec_idx) = res.Y(:, spec_idx) - peak_sum;
            fd = fraction_done + 0.1*bin_spec_completed / n_bin_spec;
            waitbar( fd,  wait_bar_handle, sprintf(['Final ' ...
                'processing: Calculating residuals ... %d of %d'], ...
                bin_spec_completed, n_bin_spec));
        end
        
        %Save the two generated collections
        fraction_done = 0.9;
        waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
            'Saving deconvolved file']);
        
        save_collection(fullfile(id_path, id_name), dec);
        
        if ~exist('dont_write_residuals.foobarbaz','file')
            % Only write the residuals if the debug file doesn't exist
            % (since writing the residuals can take a long time).
            fraction_done = 0.91;
            waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
                'Saving residual file']);

            save_collection(fullfile(resid_path, resid_name), res);
        end
        
        % Write the full deconvolution to a file in the current directory
        fraction_done = 0.92;
        waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
            'Saving full deconvolution']);
        all_peaks=cell(num_spec,1);
        for spec_idx = 1:num_spec
            for bin_idx = 1:num_bins
                all_peaks{spec_idx}=[all_peaks{spec_idx},handles.deconvolutions(bin_idx, spec_idx).value.peaks];
            end
        end
        save('saved_full_deconvolution.mat','all_peaks');
        
        %Save the deconvolved peaks in a nice csv format

        fraction_done = 0.99;
        waitbar(fraction_done, wait_bar_handle, ['Final processing: ' ...
            'Saving excel compatible peak file']);

        excel_fid=fopen(fullfile(excel_compat_path, excel_compat_name),'w');
        if excel_fid==-1
            warning('targeted_identify:no_csv', ...
                'Could not open %s to write csv file.', ...
                fullfile(excel_compat_path, excel_compat_name));
        else
            % Write header
            fprintf(excel_fid, '"Metabolite Name","ID","Peak"');
            for spec_idx = 1:num_spec
                fprintf(excel_fid, ',"Spectrum %d"', spec_idx);
            end
            fprintf(excel_fid,'\n');
            
            % Write rows
            block_idx = 1; % Index of start of next block of y values to fill/copy
            for bin_idx = 1:num_bins
                bin = handles.metab_map(bin_idx);
                block_offset = 0; % Number of rows to descend into block
                while block_offset < bin.num_peaks + 1
                    %Row-descriptive text
                    fprintf(excel_fid, '"%s",%d', ...
                        bin.compound_name, bin.id);
                    if block_offset == 0
                        fprintf(excel_fid,',"Sum"');
                    else
                        fprintf(excel_fid,',"Peak %d"', block_offset);
                    end
                    %Peak areas
                    for spec_idx = 1:num_spec
                        fprintf(excel_fid,',%f', ...
                            dec.Y(block_idx + block_offset, spec_idx));
                    end
                    fprintf(excel_fid,'\n');
                    block_offset = block_offset + 1;
                end
                block_idx = block_idx + bin.num_peaks + 1;
            end
            
            % Write MD
            specmd = handles.collection; % spectrum metadata fields
            nonmdfields = ... %fields to exclude from specmd
                intersect({'filename','input_names','x','Y', ...
                'num_samples','collection_id','type','description', ...
                'processing_log'}, fieldnames(specmd));
            specmd = rmfield(specmd, nonmdfields);
            clear('nonmdfields');
            mdfields = fieldnames(specmd);
            for fieldidx = 1:length(mdfields)
                fieldname = mdfields{fieldidx};
                % Print the field name followed by two blank columns so we
                % align with the spectrum columns
                fprintf(excel_fid,'"%s",,', fieldname);
                md_vals = specmd.(fieldname);
                if iscell(md_vals) 
                    % Print the values delimited with "" if any is not a number
                    % otherwise all are numbers and "" are not needed
                    is_string_field = any(isnan(str2double(md_vals)));
                    if is_string_field
                        fprintf(excel_fid,',"%s"', md_vals{:});
                    else
                        fprintf(excel_fid,',%s', md_vals{:});
                    end
                else
                    fprintf(excel_fid,',%g',md_vals(:));
                end
                % End the line
                fprintf(excel_fid,'\n');
            end
            
            % Done
            fclose(excel_fid);
        end
        
        %Quit
        delete(wait_bar_handle);
        delete(handles.figure1);
    end
end


% --- Executes on button press in zoom_to_bin_button.
function zoom_to_bin_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to zoom_to_bin_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom_to_bin(handles);

% --- Executes on selection change in metabolite_menu.
function metabolite_menu_Callback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to metabolite_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metabolite_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metabolite_menu

%Check that changing bin is ok
[change_is_ok, handles] = changing_spectrum_or_bin_is_ok(handles);
if change_is_ok
    %If so, change the bin
    set_bin_idx(get(hObject,'Value'), handles);
else
    %If not ok, change the menu back to its earlier value
    set(handles.metabolite_menu,'Value', handles.bin_idx);
end


% --- Executes during object creation, after setting all properties.
function metabolite_menu_CreateFcn(hObject, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to metabolite_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function spectrum_number_edit_box_CreateFcn(hObject, unused1, unused) %#ok<INUSD,DEFNU>
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
function toggle_peak_tool_ClickedCallback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to toggle_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
putdowntext('thisisnotamatlabbutton',hObject); % Call undocumented matlab toolbar button change routine
reset_plot_to_non_interactive(handles);

% --------------------------------------------------------------------
function add_peak_tool_ClickedCallback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to add_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
putdowntext('thisisnotamatlabbutton',hObject); % Call undocumented matlab toolbar button change routine
reset_plot_to_non_interactive(handles);

% --------------------------------------------------------------------
function remove_peak_tool_ClickedCallback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to remove_peak_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
putdowntext('thisisnotamatlabbutton',hObject); % Call undocumented matlab toolbar button change routine
reset_plot_to_non_interactive(handles);



% --- Executes on mouse press over axes background.
function spectrum_plot_ButtonDownFcn(hObject, unused1, unused) %#ok<INUSD>
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

% Get the handles structure
fig1=get(hObject,'Parent');
handles = guidata(fig1);

% Run the appropriate tool
if isequal(get(handles.toggle_peak_tool, 'state'),'on')
    
    % Toggle peak identification
    peak_idx = index_of_nearest_peak_to(x_pos, handles);
    if peak_idx > 0 % do nothing if there are no peaks
        pks = get_spectrum_peaks(handles);
        peak_ppm = pks(peak_idx);
        if is_identified(peak_ppm, handles)
            %Deselect peak
            remove_identification(peak_ppm, handles);
        else
            %Select peak
            xidx = index_of_nearest_x_to(peak_ppm, handles);
            newid = PeakIdentification(peak_ppm, xidx, handles.spectrum_idx, ...
                handles.metab_map(handles.bin_idx), ...
                0, get_username, get_account_id, datestr(clock));
            set_identifications([handles.identifications newid],handles);
        end
    end
    
elseif isequal(get(handles.add_peak_tool, 'state'),'on')
    
    %Add peak
    x_idx = index_of_nearest_x_to(x_pos, handles);
    add_peak(handles.collection.x(x_idx), handles);

elseif isequal(get(handles.remove_peak_tool, 'state'),'on')
    
    %Remove peak
    pk_idx = index_of_nearest_peak_to(x_pos, handles);
    if pk_idx > 0
        pks = get_spectrum_peaks(handles);
        remove_peak(pks(pk_idx), handles);
    end
    
end

% --------------------------------------------------------------------
function zoom_in_tool_ClickedCallback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to zoom_in_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom_plot(3/5, true, handles);

% --------------------------------------------------------------------
function zoom_out_tool_ClickedCallback(unused1, unused, handles)  %#ok<INUSL,DEFNU>
% hObject    handle to zoom_out_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
zoom_plot(5/3, true, handles);


% --- Executes on button press in save_and_quit_button.
function save_and_quit_button_Callback(unused1, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to save_and_quit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% The session file is just a .mat file that contains a struct
% (named session_data) 
%
% Session data has fields:  (unless otherwise specified, they come from
% handles.field_name)
% collection
% metab_map
% identifcations
% peaks
% spectrum_idx
% bin_idx
% already_autoidentified
% deconvolutions
% models
% version (set to a special number indicating the version of this program
%          - this should be increased for any changes to the data or field
%          names being saved)
% metabolite_menu_string (from get(handles.metabolite_menu,'String'); )

%Get the file to save to
[filename,pathname]=uiputfile('*.session',...
    'Choose a file in which to save your session');

%If the user cancelled, do nothing
if ~ischar(filename)
    return;
end

%Save
fullname = fullfile(pathname, filename);
session_data.version = 0.4;
session_data.metabolite_menu_string = get(handles.metabolite_menu,'String');
session_data.collection = handles.collection;
session_data.metab_map = handles.metab_map;
session_data.identifications = handles.identifications;
session_data.peaks = handles.peaks;
session_data.spectrum_idx = handles.spectrum_idx;
session_data.bin_idx = handles.bin_idx;
session_data.already_autoidentified = handles.already_autoidentified;
session_data.deconvolutions = handles.deconvolutions;
session_data.models = handles.models;

save(fullname, 'session_data');

%Quit
delete(handles.figure1);


% --- Executes on mouse press over figure background.
function figure1_ButtonDownFcn(unused2, unused1, unused) %#ok<INUSD,DEFNU>
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in should_show_deconv_box.
function should_show_deconv_box_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to should_show_deconv_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of should_show_deconv_box
update_plot(handles);
update_display(handles);

function handles = recalculate_deconv(bin_idx, spec_idx, handles)
% Calculates a new deconvolution for bin_idx, spec_idx, & sets guidata for figure1 to the new handles object

% Get the peaks 
pks = get_spectrum_peaks(handles, spec_idx);
handles = guidata(handles.figure1);

% Calculate the deconvolution
bin = handles.metab_map(bin_idx).bin;
bin_width = 2*(bin.left - bin.right);

d=RegionDeconvolution(handles.collection.x, ...
    handles.collection.Y(:, spec_idx), ...
    pks, bin_width, bin.right, bin.left, ...
    handles.models(bin_idx, spec_idx));

handles.deconvolutions(bin_idx, spec_idx).update_to(d);

guidata(handles.figure1, handles);

function handles = align_peaks_with_deconv(bin_idx, spec_idx, handles)
% Aligns the peaks in handles with the deconvolution for bin_idx, spec_idx.  
%
% Does nothing if the current deconvolution is has not been initialized

if ~handles.deconvolutions(bin_idx, spec_idx).exists
    return;
end
d=handles.deconvolutions(bin_idx, spec_idx).value;


pks = get_spectrum_peaks(handles, spec_idx);
new_pks = [d.peaks.location];
old_pks = get_spectrum_and_bin_peaks(handles, bin_idx, spec_idx);
costs = zeros(length(old_pks), length(new_pks)); % Row:old peak, col: new peak
for i=1:length(old_pks)
    costs(i,:) = abs(new_pks - old_pks(i));
end
new_idxs = munkres(costs);
new_pk_val = new_pks(new_idxs); %new_pk_val(i) is value to replace old_pks(i)

% Update the identifications and peak locations
handles = update_peak_identifications_for(bin_idx, spec_idx, old_pks, ...
    new_pk_val, handles);

translated_pks = substitute(pks, old_pks, new_pks);
handles = set_spectrum_peaks_no_gui(spec_idx, translated_pks, handles);

% --- Executes on button press in update_deconv_button.
function update_deconv_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to update_deconv_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
bin_idx = handles.bin_idx;
spec_idx = handles.spectrum_idx;

handles = recalculate_deconv(bin_idx, spec_idx, handles);

update_plot(handles);
update_display(handles);
    


% --- Executes on selection change in baseline_menu.
function baseline_menu_Callback(hObject, unused, handles) %#ok<INUSL,DEFNU>
% hObject    handle to baseline_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns baseline_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from baseline_menu
idx = get(hObject,'Value');
m = handles.models(handles.bin_idx, handles.spectrum_idx);
switch idx
    case 1
        m.baseline_type = 'spline';
    case 2
        m.baseline_type = 'v';
    case 3
        m.baseline_type = 'line_up';
    case 4
        m.baseline_type = 'line_down';
    case 5
        m.baseline_type = 'constant';
    otherwise
        error('targeted_identify:bad_baseline_option', ...
            'Unknown value (%d) for baseline menu index', idx);
end
handles.models(handles.bin_idx, handles.spectrum_idx) = m;
guidata(handles.figure1, handles);

% --- Executes during object creation, after setting all properties.
function baseline_menu_CreateFcn(hObject, unused, unused2) %#ok<DEFNU,INUSD>
% hObject    handle to baseline_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseline_area_penalty_edit_box_Callback(hObject, unused, handles) %#ok<DEFNU,INUSL>
% hObject    handle to baseline_area_penalty_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline_area_penalty_edit_box as text
%        str2double(get(hObject,'String')) returns contents of baseline_area_penalty_edit_box as a double
v = str2double(get(hObject,'String'));
if ~isnan(v)
    m=handles.models(handles.bin_idx, handles.spectrum_idx);
    m.baseline_area_penalty = v;
    handles.models(handles.bin_idx, handles.spectrum_idx) = m;
    guidata(handles.figure1, handles);
end

% --- Executes during object creation, after setting all properties.
function baseline_area_penalty_edit_box_CreateFcn(hObject, unused, unused2) %#ok<INUSD,DEFNU>
% hObject    handle to baseline_area_penalty_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function width_variance_penalty_edit_box_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to width_variance_penalty_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of width_variance_penalty_edit_box as text
%        str2double(get(hObject,'String')) returns contents of width_variance_penalty_edit_box as a double
v = str2double(get(hObject,'String'));
if ~isnan(v)
    m=handles.models(handles.bin_idx, handles.spectrum_idx);
    m.linewidth_variation_penalty = v;
    handles.models(handles.bin_idx, handles.spectrum_idx) = m;
    guidata(handles.figure1, handles);
end


% --- Executes during object creation, after setting all properties.
function width_variance_penalty_edit_box_CreateFcn(hObject, unused, unused2) %#ok<INUSD,DEFNU>
% hObject    handle to width_variance_penalty_edit_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in sync_peaks_with_deconv_button.
function sync_peaks_with_deconv_button_Callback(unused, unused2, handles) %#ok<INUSL,DEFNU>
% (unused)  hObject    handle to sync_peaks_with_deconv_button (see GCBO)
% (unused2) eventdata  reserved - to be defined in a future version of MATLAB
%           handles    structure with handles and user data (see GUIDATA)

bin_idx = handles.bin_idx;
spec_idx = handles.spectrum_idx;

% Find new location for each peak
handles = align_peaks_with_deconv(bin_idx, spec_idx, handles);

% Mark current bin as up-to-date even if it moved the peaks in the bin -
% other bins that depend on it will still be marked as not up-to-date
cur_value=handles.deconvolutions(bin_idx, spec_idx).value;
handles.deconvolutions(bin_idx, spec_idx).update_to(cur_value);

% Set guidata
guidata(handles.figure1, handles);

% Update gui
update_plot(handles);
update_display(handles);


% --------------------------------------------------------------------
function vertical_zoom_in_tool_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to vertical_zoom_in_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.auto_y_zoom = false;
zoom_plot(3/5, false, handles);
guidata(handles.figure1, handles);


% --------------------------------------------------------------------
function vertical_zoom_out_tool_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to vertical_zoom_out_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.auto_y_zoom = false;
zoom_plot(5/3, false, handles);
guidata(handles.figure1, handles);


% --- Executes on button press in auto_deconvolve_button.
function auto_deconvolve_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to auto_deconvolve_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the current bin and spectrum indices
bin_idx = handles.bin_idx;
spec_idx = handles.spectrum_idx;

% Get the bin boundary
bin = handles.metab_map(bin_idx).bin;

% Calculate the noise standard deviation
num_noise_pts = 100;
noise_std = std(handles.collection.Y(num_noise_pts:2*num_noise_pts, spec_idx));

% Set the number of points used for fitting the neighborhood of each local
% peak
pk_pts = 25;

% Get the points for the bin
in_bin = handles.collection.x <= bin.left & handles.collection.x >= bin.right;
fit_indices = find(in_bin);
bx = handles.collection.x(in_bin);
by = handles.collection.Y(in_bin, spec_idx);

% Save the global figure handle because waitbar can cause problems
global_fig_tmp = gcf;

% Do the deconvolution while displaying a progress bar
wait_h = waitbar(0, sprintf('Auto deconvolution pass %s: peak %s of %s', ...
    'Initializing', '0', 'unknown'));

peaks=auto_dirty_deconvolve_pos_resid(bx, by, pk_pts, 5.5*noise_std, noise_std,...
    @(frac_done, pass_num, peak_num, num_peaks) waitbar(frac_done, ...
    wait_h, sprintf('Auto deconvolution pass %d: peak %d of %d', ...
    pass_num, peak_num, num_peaks)));

close(wait_h);

% Restore the global figure handle
figure(global_fig_tmp);


% Set the region deconvolution
d = RegionDeconvolution();
d = d.set_from_peaks(peaks, bx, fit_indices, by'); %#ok<FNDSB>
handles.deconvolutions(bin_idx, spec_idx).update_to(d);

% Eliminate the old peaks and set the new ones
pks = get_spectrum_peaks(handles, spec_idx);
pks = pks(pks > bin.left | pks < bin.right); % Keep only peaks not in the bin
pks = sort([pks, peaks.location],'descend'); % Add the new peaks
handles = set_spectrum_peaks_no_gui(spec_idx, pks, handles);

% Update the global guidata
guidata(handles.figure1, handles);

% Update the display
update_plot(handles);
update_display(handles);


% --------------------------------------------------------------------
function vertical_zoom_all_tool_ClickedCallback(hObject, eventdata, handles) %#ok<DEFNU,INUSL>
% hObject    handle to vertical_zoom_all_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.auto_y_zoom = true;

xlims=xlim;
x = handles.collection.x;
in_lims = xlims(1) <= x & x <= xlims(2);
y = handles.collection.Y(in_lims, handles.spectrum_idx);
yrange = max(y)-min(y);
zoom_to_box(xlims(1),xlims(2),min(y)-yrange/20,max(y)+yrange/20);
handles.auto_y_zoom = false;
guidata(handles.figure1, handles);
%update_plot(handles);



function rough_peak_window_ppm_edit_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to rough_peak_window_ppm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rough_peak_window_ppm_edit as text
%        str2double(get(hObject,'String')) returns contents of rough_peak_window_ppm_edit as a double

% Calculate the minimum allowable ppm
collection = handles.collection;
x = collection.x;
num_samp = length(x);
if num_samp >= 2
    ppm_between_samples = (max(x)-min(x))/(num_samp-1);
elseif num_samp == 1
    ppm_between_samples = 0;
else
    msgbox(['To do operations on the spectra they must have at least '...
        'one sample point.'],'Not enough samples','Error');
    ppm_between_samples = 0;
end
assert(ppm_between_samples >= 0);
min_window_width_samples = 5; % 5 samples wide will contain 4 intervals between samples, and at least 4 samples total
min_window_width_ppm = (min_window_width_samples - 1)*ppm_between_samples;

% Check the entry typed in and set the value if it is valid
entry  = str2double(get(hObject,'String'));
invalid_entry = true;
if ~isnan(entry) %If the user typed a number
    if entry >= min_window_width_ppm
        m=handles.models(handles.bin_idx, handles.spectrum_idx);
        m.rough_peak_window_width = entry;
        handles.models(handles.bin_idx, handles.spectrum_idx) = m;
        guidata(handles.figure1, handles);

        invalid_entry = false;
    else
        msgbox(sprintf(['The window must be at least %d samples '...
            'wide (%g ppm)'], min_window_width_samples, ...
            min_window_width_ppm),'Window too small','Error');
    end
end

% If the value typed into the box was not a valid field value, reset the
% edit box to the current field value.
if invalid_entry
	m = handles.models(handles.bin_idx, handles.spectrum_idx);
    val = m.rough_peak_window_width;
    set(hObject,'String',num2str(val,6));
end


% --- Executes during object creation, after setting all properties.
function rough_peak_window_ppm_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to rough_peak_window_ppm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rough_peak_max_width_edit_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to rough_peak_max_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rough_peak_max_width_edit as text
%        str2double(get(hObject,'String')) returns contents of rough_peak_max_width_edit as a double

% Check the entry typed in and set the value if it is valid, reset the edit
% box to the current value if the value typed is invalid
entry  = str2double(get(hObject,'String'));

if ~isnan(entry) ... % If the user typed a number
   && entry > 0      % And the peak width is non-negative
    m=handles.models(handles.bin_idx, handles.spectrum_idx);
    m.max_rough_peak_width = entry;
    handles.models(handles.bin_idx, handles.spectrum_idx) = m;
    guidata(handles.figure1, handles);
else
    m = handles.models(handles.bin_idx, handles.spectrum_idx);
    val = m.max_rough_peak_width;
    set(hObject,'String',num2str(val,6));
end


% --- Executes during object creation, after setting all properties.
function rough_peak_max_width_edit_CreateFcn(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to rough_peak_max_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
