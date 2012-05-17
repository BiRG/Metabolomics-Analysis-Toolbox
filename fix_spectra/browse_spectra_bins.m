function varargout = browse_spectra_bins(varargin)
% BROWSE_SPECTRA_BINS MATLAB code for browse_spectra_bins.fig
% Opens window to browse spectra and their relationship to a reference spectrum.
%      
%      use_bin=browse_spectra_bins({spectra, use_bin, use_spectrum, display_indices})
%      opens the dialog to browse the spectra at display_indices in
%      spectra. spectra{s}.Y(b,s) contains the value for bin b measured
%      for spectrum s.
%      The whether a bin is selected is governed by use_bin.
%      use_bin(b) is true if for all c spectra{c}.x(b) should be
%      used as a bin when calculating the normalization constant, false 
%      otherwise. 
%
%      Input
%      -----
%      spectra         - a cell array of spectral collections as returned
%                        by load_collections.
%      use_bin         - use_bin(b) is true if for all c spectra{c}.x(b) 
%                        should be used as a bin when calculating the 
%                        normalization constant, false otherwise. 
%      use_spectrum    - use_spectrum{c}(s) is true if and only if
%                        spectra{c}.Y(:,s) should be used in calculating 
%                        the reference spectrum.
%      display_indices - display_indices(i,:) is a pair (c,s) meaning that
%                        spectrum{c}.Y(:,s) is the i'th spectrum to
%                        display in the browser
% 
%      Output
%      ------
%      use_bin - the bins selected by the user during browsing or empty if
%                 the caller should leave its bins unchanged.
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

% Last Modified by GUIDE v2.5 15-May-2012 22:48:53

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

% Get command-line arguments
handles.spectra = varargin{1}{1};
handles.use_bin = varargin{1}{2};
handles.use_spectrum = varargin{1}{3};
handles.display_indices = varargin{1}{4};
handles.display_index = 1; % We will guarantee display_indices is non-empty later
handles.zoom_h = zoom(handles.figure1); %TODO document

% Error check command-line arguments
if isempty(handles.spectra)
    error('browse_spectra_bins:input_err','spectra argument must be non-empty');
elseif ~iscell(handles.spectra)
    error('browse_spectra_bins:input_err','spectra argument must be cell array');
elseif ~isfield(handles.spectra{1},'Y') || ~isfield(handles.spectra{1},'x')
    error('browse_spectra_bins:input_err','spectra argument must have x and y fields');
elseif ~only_one_x_in(handles.spectra)
    error('browse_spectra_bins:input_err','all collections in spectra argument must have identical x fields');
elseif (length(size(handles.use_bin)) ~= length(size(handles.spectra{1}.x))) || ...
        length(handles.use_bin) ~= length(handles.spectra{1}.x)
    error('browse_spectra_bins:input_err','use_bin must be the same size as the spectra x fields');
elseif ~iscell(handles.use_spectrum)
    error('browse_spectra_bins:input_err','use_spectrum argument must be cell array');
elseif length(handles.use_spectrum) ~= length(handles.spectra)
    error('browse_spectra_bins:input_err','use_spectrum argument must have the same length as the spectra argument');
elseif isempty(handles.display_indices)
    return; % nothing to display
elseif size(handles.display_indices,2) ~= 2
    error('browse_spectra_bins:input_err','display_indices argument must have 2 columns');
end

for i=1:size(handles.display_indices,1)
    c=handles.display_indices(i,1);
    s=handles.display_indices(i,2);
    if c < 1 || c > length(handles.spectra) || ...
       s < 1 || s > handles.spectra{c}.num_samples
        error('browse_spectra_bins:input_err',['display_indices '...
            'argument index %d is [%d, %d] which does not refer to '...
            'a valid spectrum'], i, c, s);
    end 
end

% Draw the UI
update_ui(handles)

% Choose default command line output for browse_spectra_bins
handles.output = false(0);

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes browse_spectra_bins wait for user response (see UIRESUME)
uiwait(handles.figure1);

function update_ui(handles)
% Draw the plots and update other parts of the user interface depending on
% the current state of the dialog
%
% handles    structure with handles and user data (see GUIDATA)
c=handles.display_indices(handles.display_index,1);
s=handles.display_indices(handles.display_index,2);
set(handles.spectrum_properties_edit, 'String', ...
    spectrum_properties_string(handles.spectra{c},s));

ref = median_spectrum(handles.spectra, handles.use_spectrum);
handles.spectra = set_quotients_field(handles.spectra, ref);
selected_quotients = handles.spectra{c}.quotients(handles.use_bin, :);
medians = prctile(selected_quotients,50);
mult = medians(s);

hold(handles.spectrum_axes, 'off');
plot(handles.spectrum_axes, handles.spectra{c}.x, ...
    handles.spectra{c}.Y(:,s).*mult, '-b','LineWidth',1);
hold(handles.spectrum_axes, 'all');
plot(handles.spectrum_axes, handles.spectra{c}.x, ref.Y, '--r','LineWidth',1);

% Clear the second axes
cla(handles.quotient_axes);

% Draw the bin badness value on the second axis
if get(handles.quotient_outlier_radio, 'Value')
    %Quotient outlier
    if sum(handles.use_bin) >= 2
        scaled_quotients = quotient_outlyingness(handles.spectra{c}.quotients);
    else
        scaled_quotients = handles.spectra{c}.quotients;
    end
    scaled_quotients = abs(scaled_quotients(:,s));
    % Truncate data at 5 iqr
    scaled_quotients(scaled_quotients > 5) = 5;
    % Draw the line on the second axes
    line(handles.spectra{c}.x, scaled_quotients, 'Color','g','Parent', handles.quotient_axes);
    % Turn on the grid at the two critical values
    set(handles.quotient_axes,'YTick',[1.5,3]);
    set(handles.quotient_axes,'YGrid','on');
else
    % Use the bin multimodality - 1-p_value for dip test
    wait_h=waitbar(0,'Starting multimodality calculation');
    num_spectra=num_spectra_in(handles.spectra);
    scaled_spectra = zeros(length(handles.use_bin),num_spectra);
    first_unused = 1;
    for col=1:length(handles.spectra)
        waitbar((col-1)/length(handles.spectra), wait_h, sprintf(...
            'Temp. quotient normalizing collection %d', ...
            handles.spectra{col}.collection_id));
        selected_quotients = handles.spectra{col}.quotients(handles.use_bin, :);
        mults = prctile(selected_quotients,50);
        last_to_use = first_unused + length(mults) - 1;
        mults = repmat(mults, length(handles.use_bin),1);
        tmp_scaled = (handles.spectra{col}.Y).*mults;
        scaled_spectra(:,first_unused:last_to_use)=tmp_scaled;
        first_unused = last_to_use + 1;
    end
    % no_nan_bins is the i'th bin after removing NaN values
    no_nan_bins=cell(size(scaled_spectra,1));
    for bin=1:size(scaled_spectra,1)
        waitbar((bin-1)/size(scaled_spectra,1), wait_h, sprintf(...
            'Removing NaN''s from bin %d', bin));
        cur_bin = scaled_spectra(bin, :);
        no_nan_bins{bin}=cur_bin(~isnan(cur_bin));
    end
    % unique_lengths is the different sample sizes after you remove NaN bins
    lengths = cellfun(@(in) length(in), no_nan_bins);
    unique_lengths = unique(lengths);
    unique_lengths = unique_lengths(unique_lengths >= 4);
    % Calculate dips on uniform for given sample sizes which is a lower
    % bound on dips for any unimodal function. Ignore lengths less than 4 -
    % dip is not defined for those lengths
    unique_lengths = unique_lengths(unique_lengths >= 4);
    if ~isfield(handles, 'unif_dip')
        handles.unif_dip = cell(max(unique_lengths),1);
    end
    for i=1:length(unique_lengths)
        waitbar((i-1)/length(unique_lengths), wait_h, sprintf(['Calculating '...
            'Hartigan Null Distribution for length %d'], ...
            unique_lengths(i)));
        if length(handles.unif_dip{unique_lengths(i)}) < 2000
            handles.unif_dip{unique_lengths(i)}=hartigansdipofuniform(2000, unique_lengths(i));
        end
    end

    guidata(handles.figure1, handles);
    p_values = zeros(length(no_nan_bins));
    for i = 1:length(no_nan_bins)
        waitbar((i-1)/length(no_nan_bins), wait_h, sprintf(...
            'Calculating unimodality p-value for bin %d', i));
        len = length(no_nan_bins{i});
        if len < 4
            p_values(i) = 1; %Not enough evidence to reject unimodality - not enough points
        elseif all(no_nan_bins{i}(1)==no_nan_bins{i})
            p_values(i) = 1; % more than 4 samples and all identical? No evidence of multimodality
        else
            dip = hartigansdiptest(no_nan_bins{i});
            p_values(i) = sum(dip < handles.unif_dip{len})/length(handles.unif_dip{len});
        end
    end
    delete(wait_h);
    line(handles.spectra{c}.x, 1-p_values, 'Color','k','Parent', handles.quotient_axes);    
    set(handles.quotient_axes,'YTick',[0.8,0.95]);
    set(handles.quotient_axes,'YGrid','on');
end
set(handles.spectrum_axes, 'XDir', 'reverse');
set(handles.quotient_axes, 'XDir', 'reverse');
linkaxes([handles.spectrum_axes, handles.quotient_axes],'x');



% --- Outputs from this function are returned to the command line.
function varargout = browse_spectra_bins_OutputFcn(hObject, eventdata, handles)  %#ok<INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

if isstruct(handles)
    % Get command line output from handles structure
    varargout{1} = handles.output;
    delete(hObject);
else
    % The close button was pressed and the handles object is invalid return
    % empty logical array to indicate leaving the bins unchanged
    varargout{1} = false(0);
    % No need to delete the object, it has already been deleted
end



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


% --- Executes on button press in close_button.
function close_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to close_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.output = false(0);
guidata(handles.figure1, handles);
uiresume(handles.figure1);

% --- Executes on button press in previous_button.
function previous_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to previous_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.display_index > 1
    handles.display_index = handles.display_index - 1;
    guidata(handles.figure1, handles);
    update_ui(handles);
end

% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.display_index < size(handles.display_indices, 1)
    handles.display_index = handles.display_index + 1;
    guidata(handles.figure1, handles);
    update_ui(handles);
end

% --- Executes when selected object is changed in diagnostics_group.
function diagnostics_group_SelectionChangeFcn(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to the selected object in diagnostics_group 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

if get(handles.quotient_outlier_radio, 'Value')
    if sum(handles.use_bin) < 2
        msgbox(['Not enough bins selected to scale quotients. They ' ...
            'will be left unchanged. Select at least two bins to properly ' ...
            'scale quotients'],'Not enough bins for scaling','warn');
    end
else
    if num_spectra_in(handles.spectra) < 4
        msgbox(['Not enough spectra for multimodality calculation. ' ...
            'A multimodality of 0 will be used.'], ...
            'Not enough spectra for multimodality','warn');
    end
end
update_ui(handles);

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


% --------------------------------------------------------------------
function zoom_in_tool_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to zoom_in_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmp(get(handles.zoom_h,'Direction'),'in')
    set(handles.zoom_h, 'Enable', 'on');
    set(handles.zoom_h, 'Direction', 'in');
elseif strcmp(get(handles.zoom_h,'Enable'),'off')
    set(handles.zoom_h, 'Enable', 'on');
    set(handles.zoom_h, 'Direction', 'in');
else
    set(handles.zoom_h, 'Enable', 'off');
end    

% --------------------------------------------------------------------
function zoom_out_tool_ClickedCallback(hObject, eventdata, handles) %#ok<INUSL,DEFNU>
% hObject    handle to zoom_out_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~strcmp(get(handles.zoom_h,'Direction'),'out')
    set(handles.zoom_h, 'Enable', 'on');
    set(handles.zoom_h, 'Direction', 'out');
elseif strcmp(get(handles.zoom_h,'Enable'),'off')
    set(handles.zoom_h, 'Enable', 'on');
    set(handles.zoom_h, 'Direction', 'out');
else
    set(handles.zoom_h, 'Enable', 'off');
end    


% --------------------------------------------------------------------
function pan_tool_ClickedCallback(hObject, eventdata, handles) %#ok<INUSD,DEFNU>
% hObject    handle to pan_tool (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan
