function varargout = prob_quotient_norm_dialog(varargin)
% Return normalization constants for spectra using the probabilistic quotient normalization algorithm
%
%      prob_quotient_norm_dialog({binned_spectra, use_bin}) opens the
%      dialog to compute the normalization constants for all the spectra in
%      the binned_spectra using the bins in the logical array
%      use_bin. use_bin(b) is true if for all c binned_spectra{c}.x(b) should be
%      used as a bin, false otherwise. binned_spectra is a cell array of
%      spectral collections as returned by load_collections.
%
%      NOTE: the x field of all the collections in binned_spectra must be
%      identical. If not, an error is raised. Check with
%      only_one_x_in.m before calling prob_quotient_norm_dialog
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
%                   the when the dialog was most recently raised or
%                   created. normalization_factors(c,s) is the
%                   normalization factor by which spectrum s in
%                   the collection binned_spectra{c} should be multiplied
%                   in order to normalize it with respect to concentration.
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

% Last Modified by GUIDE v2.5 17-May-2012 16:09:23

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

% Initialize handles structure using command line arguments
handles.binned_spectra = varargin{1}{1};
if ~only_one_x_in(handles.binned_spectra)
    error('prob_quotient:one_x',['All the x vectors in the spectra ' ...
        'collections passed to prob_quotient_norm_dialog must be ' ...
        'identical.']);
end

handles.use_bin = varargin{1}{2};
if size(handles.use_bin, 2) ~= 1 %Ensure that column vector
    handles.use_bin = (handles.use_bin)';
end

use_spectrum = cell(size(handles.binned_spectra));
for i=1:length(handles.binned_spectra)
    num_spectra = handles.binned_spectra{i}.num_samples;
    use_spectrum{i} = true(1, num_spectra);
end

handles = set_use_spectrum(handles, use_spectrum);


% Set default command line output for prob_quotient_norm_dialog to the same
% as a cancelled
handles.output = {hObject, true(1), true, ...
    'No changes made during probabilistic quotient normalization'};

% Update handles structure
guidata(hObject, handles);

update_ui(handles);

% UIWAIT makes prob_quotient_norm_dialog wait for user response (see UIRESUME)
uiwait(handles.figure1);

function handles = set_use_spectrum(handles, use_spectrum)
% Sets use_spectrum and the other values that depend on it in handles, returning the result
%
% Remember to do a guidata(handles.figure1, ...) on the return value.
%
% The other values that depend on use_spectrum are handles.ref_spectrum and
% handles.binned_spectra (the quotients field)
%
% handles      - user data and gui handles
% use_spectrum - cell array of logical row vectors. use_spectrum{i} has one
%                entry for each spectrum in handles.binned_spectra{i}
handles.use_spectrum = use_spectrum;
handles.ref_spectrum = median_spectrum(handles.binned_spectra, use_spectrum);
handles.binned_spectra = set_quotients_field(handles.binned_spectra, handles.ref_spectrum);


function update_ui(handles)
% Update the UI according to the program state as reflected in the handles
% object.
%
% handles structure with handles and user data (see GUIDATA)

num_spec = num_spectra_in(handles.binned_spectra);
set(handles.bin_count_text, 'String', sprintf(...
    '%d of %d bins used to calculate normalization multiplier', ...
    sum(handles.use_bin), length(handles.use_bin)));
set(handles.spectra_count_text, 'String', sprintf(...
    '%d of %d spectra used to calculate normalization multiplier', ...
    sum(cellfun(@sum, handles.use_spectrum)), num_spec));


% Calculate the quotient quartile skewnesses
skewnesses = zeros(num_spec, 1);
collection_indices_for_spectrum = zeros(num_spec, 2); %collection_indices(i,:)=[j,k] means that binned_spectra{j}.Y(:,k) is the spectrum whose skewness is recored in skewnesses(i)
first_empty = 1;
for c=1:length(handles.binned_spectra)
    num_samples = handles.binned_spectra{c}.num_samples;
    selected_quotients = iqr_normed_quotients(handles.binned_spectra{c}.quotients(handles.use_bin, :));
    last_filled = first_empty+num_samples-1;
    skewnesses(first_empty:last_filled)= quartile_skewness(selected_quotients);
    collection_indices_for_spectrum(first_empty:last_filled,1)=c*ones(1,num_samples);
    collection_indices_for_spectrum(first_empty:last_filled,2)=(1:num_samples)';
    first_empty = first_empty + num_samples;
end

% Calculate the bin_width
if length(skewnesses) >= 10
    bin_width = freedman_diaconis(skewnesses);
else
    num_bins  = 2*length(skewnesses);
    if num_bins > 0
        bin_width = (max(skewnesses)-min(skewnesses))*1.01/num_bins;
    else
        bin_width = 0.00001;
    end
end
if bin_width <= 0 %Ensure that the next loop terminates
    bin_width = 0.00001;
end

% Create the bin edges ensuring that the last bin does not end on the
% maximum value (to avoid problems with a special case on histc)
skew_bin_edges=min(skewnesses):bin_width:max(skewnesses);
while skew_bin_edges(end) <= max(skewnesses)
    skew_bin_edges = [skew_bin_edges, skew_bin_edges(end)+bin_width]; %#ok<AGROW>
end
skew_bin_centers = (skew_bin_edges(1:end-1)+skew_bin_edges(2:end))/2;

% Count the number of spectra in each bin
[skew_bin_counts, bin_for_spectrum]=histc(skewnesses, skew_bin_edges);
hist_handle = bar(skew_bin_centers, skew_bin_counts(1:end-1)); 
xlabel(handles.skewness_histogram_axes, 'Quartile Skewness of Quotient Distribution');
ylabel(handles.skewness_histogram_axes, 'Number of Spectra');

% Pass through clicks on the bars to the main axis
set(hist_handle, 'HitTest', 'off');

% Set the axis callback to respond to those clicks
set(handles.skewness_histogram_axes, 'ButtonDownFcn', ...
    @(hObject, eventdata) prob_quotient_norm_dialog('skewness_histogram_axes_ButtonDownFcn',...
        hObject,eventdata,guidata(hObject), skew_bin_counts, skew_bin_edges, bin_for_spectrum, collection_indices_for_spectrum));

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
function normalize_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to normalize_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

multipliers = pq_multipliers(handles.binned_spectra, handles.use_bin);

spectrum_list_txt = to_str(cell_find(handles.use_spectrum));
bin_centers_list_txt = to_str(handles.ref_spectrum.x(~handles.use_bin));
normalization_facts_txt = to_str(multipliers);

log_text = sprintf(['  Probabilistic quotient normalization '...
    'using spectra %s to generate a reference spectrum and ignoring ' ...
    'bins centered at %s in calculating the quotients. This resulted ' ...
    'in normalization factors of %s.'], ...
    spectrum_list_txt, bin_centers_list_txt, normalization_facts_txt);

handles.output = {handles.figure1, false, multipliers, log_text};

guidata(handles.figure1, handles);

uiresume(handles.figure1);

% --- Executes on button press in select_ref_spectra_button.
function select_ref_spectra_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to select_ref_spectra_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = spectrum_inclusion_dialog({handles.binned_spectra, handles.use_spectrum});

if out{2}; return; end %Was cancelled

used_in_each_collection = cellfun(@(col) sum(col), out{3});
total_used = sum(used_in_each_collection);
if total_used > 0
    handles = set_use_spectrum(handles, out{3});
    guidata(handles.figure1, handles);
    update_ui(handles);
else
    msgbox(['You must select at least one spectrum to use in ' ...
        'generating the reference spectrum. Ignoring empty selection.'],...
        'Error: no spectra selected', 'error');
end
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


% --- Executes on mouse press over axes background.
function skewness_histogram_axes_ButtonDownFcn(hObject, eventdata, handles, skew_bin_counts, skew_bin_edges, bin_for_spectrum, collection_indices_for_spectrum) %#ok<INUSL>
% hObject    handle to skewness_histogram_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the last clicked point
pt=get(hObject, 'CurrentPoint');
x=pt(1,1); y=pt(1,2);

% Calculate which bin horizontally
bin_number = find(histc(x, skew_bin_edges));
if isempty(bin_number)
    %No bin was clicked on, do nothing
    return;
end
if length(bin_number) > 1
    warning('prob_quotient_norm_dialog:mult_bins_click','Multiple bins for click - taking the first.');
    bin_number = bin_number(1);
end

% Calculate whether the click is inside the bin
bin_height = skew_bin_counts(bin_number);
if y > bin_height
    %Clicked above the bin, do nothing
    return;
end

% Get the coordinates of the spectra in that bin
spectra_in_bin=bin_for_spectrum==bin_number;
spectral_indices = collection_indices_for_spectrum(spectra_in_bin,:);
browse_spectra_bins({handles.binned_spectra, handles.use_bin, handles.use_spectrum, spectral_indices});


% --- Executes on button press in autoselect_bins_button.
function autoselect_bins_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% Changes the figure1 guidata handles structure by removing undesirable bins from use_bins
%
% hObject    handle to autoselect_bins_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if sum(handles.use_bin) == 0
    msgbox('Error: No bins are selected. This should never happen.','Error: no bins','error');
    return;
elseif sum(handles.use_bin) == 1
    msgbox('Only one bin is selected. Cannot exclude any more.','Can''t exclude more','help');
    return;
end
wait_h = waitbar(0,'Initializing auto-exclusion');
%Ensure that use_bin is a row vector (if it is a vector -- which it ought to be)
if size(handles.use_bin,2) > 1
    handles.use_bin = handles.use_bin';
end

% Each pass through the loop recalculate the iqrs and remove the 
% worst-offending outliers - first the extreme outliers, then if none are 
% left, the inner fence outliers. Stop when there are no outliers or when
% you can't remove the outliers without running out of bins.
last_removed = 'First removal.';
while true
    already_removed = ~handles.use_bin;
    wait_text = sprintf('%d/%d remaining. %s', ...
        sum(handles.use_bin), length(handles.use_bin), last_removed);
    waitbar(sum(~handles.use_bin)/length(handles.use_bin), wait_h, ...
        wait_text);
    
    % Flatten the quotients field and scale the quotients to the iqr for their
    % spectrum
    scaled_quotients = zeros(length(handles.use_bin),num_spectra_in(handles.binned_spectra));
    first_empty = 1;
    for col = 1:length(handles.binned_spectra)
        last_used = first_empty + handles.binned_spectra{col}.num_samples - 1;
        scaled_quotients(:, first_empty:last_used) = quotient_outlyingness(handles.binned_spectra{col}.quotients, handles.use_bin);
    end

    % Select bins to remove as remove bins those over 3 iqr away from the
    % median
    last_removed = 'Removed > 3 iqr.';
    to_remove = any(abs(scaled_quotients) > 3,2);
    to_remove = to_remove & ~already_removed;

    % Break out of the loop if we didn't remove anything this pass or if
    % removing what is left would leave us with no bins. Otherwise update
    % handles
    if ~any(to_remove)
        break
    end
    new_use_bin = handles.use_bin & ~to_remove;
    if ~any(new_use_bin)
        break;
    else
        handles.use_bin = new_use_bin;
    end
end

% Get rid of the wait-box
delete(wait_h);

% Update the handles structure
guidata(handles.figure1, handles);
update_ui(handles);

% --- Executes on button press in see_spectra_button.
function see_spectra_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to see_spectra_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp_all = zeros(num_spectra_in(handles.binned_spectra),2);
curidx = 1; 
for c=1:length(handles.binned_spectra)
    for s=1:handles.binned_spectra{c}.num_samples
        disp_all(curidx,:)=[c,s]; 
        curidx=curidx+1; 
    end
end
browse_spectra_bins({handles.binned_spectra, handles.use_bin, handles.use_spectrum, disp_all});
