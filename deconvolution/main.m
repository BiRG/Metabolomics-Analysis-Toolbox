function varargout = main(varargin)
% MAIN M-file for main.fig
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
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help main

% Last Modified by GUIDE v2.5 21-Sep-2011 16:53:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
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

% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

addpath('../common_scripts');
addpath('../common_scripts/cursors');
addpath('dab');
addpath('visualize_deconvolution');

handles.collection = {};
handles.dirty = true;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_pushbutton.
function load_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collections = load_collections;
if isempty(collections)
    return
end
if length(collections) > 1
    msgbox('Only one collection can be loaded into this program.');
    return;
end

collection = collections{1};

max_spectrum = collection.Y(:,1)';
min_spectrum = collection.Y(:,1)';
for s = 1:size(collection.Y,2)
    max_spectrum = max([max_spectrum;collection.Y(:,s)']);
    min_spectrum = min([min_spectrum;collection.Y(:,s)']);
end
setappdata(gcf,'min_spectrum',min_spectrum);
setappdata(gcf,'max_spectrum',max_spectrum);

if isfield(handles.collection,'spectra')
    collection = rmfield(collection,'spectra');
end
setappdata(gcf,'collection',collection);

% Initialize the plots
setappdata(gcf,'s',1); % Spectra index
refresh_axes2(handles);

% If not set, set the reference
reference = getappdata(gcf,'reference');
if isempty(reference)
    reference = {};
    reference.x = collection.x;
    reference.y = collection.Y(:,1);
    setappdata(gcf,'reference',reference);

    refresh_axes1(handles);
end
linkaxes([handles.axes1,handles.axes2],'xy');

% --- Executes on button press in get_pushbutton.
function get_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to get_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collections = get_collections;
if isempty(collections)
    return
end
if length(collections) > 1
    msgbox('Only one collection can be loaded into this program.');
    return;
end

collection = collections{1};

max_spectrum = collection.Y(:,1)';
min_spectrum = collection.Y(:,1)';
for s = 1:size(collection.Y,2)
    max_spectrum = max([max_spectrum;collection.Y(:,s)']);
    min_spectrum = min([min_spectrum;collection.Y(:,s)']);
end
setappdata(gcf,'min_spectrum',min_spectrum);
setappdata(gcf,'max_spectrum',max_spectrum);

if isfield(handles.collection,'spectra')
    collection = rmfield(collection,'spectra');
end
setappdata(gcf,'collection',collection);

% Initialize the plots
setappdata(gcf,'s',1); % Spectra index
refresh_axes2(handles);

% If not set, set the reference
reference = getappdata(gcf,'reference');
if isempty(reference)
    reference = {};
    reference.x = collection.x;
    reference.y = collection.Y(:,1);
    setappdata(gcf,'reference',reference);

    refresh_axes1(handles);
end
linkaxes([handles.axes1,handles.axes2],'xy');

% --- Executes on button press in previous_button.
function previous_button_Callback(hObject, eventdata, handles)
% hObject    handle to previous_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
s = s - 1;
if s == 0
    return;
end
setappdata(gcf,'s',s); % Spectra index

refresh_axes2(handles);

% --- Executes on button press in next_button.
function next_button_Callback(hObject, eventdata, handles)
% hObject    handle to next_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = getappdata(gcf,'collection');
s = getappdata(gcf,'s');
s = s + 1;
[dps,num_spectra] = size(collection.Y);
if s > num_spectra
    return;
end
setappdata(gcf,'s',s); % Spectra index

refresh_axes2(handles);

% --- Executes on button press in find_peaks_button.
function find_peaks_button_Callback(hObject, eventdata, handles)
% hObject    handle to find_peaks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

append_to_log(handles,sprintf('Finding peaks'));

min_width = 30;
collection = getappdata(gcf,'collection');
[num_variables,num_spectra] = size(collection.Y);
collection.maxs = {};
collection.mins = {};
collection.include_mask = {};
collection.BETA = {};
collection.match_ids = {};
collection.Y_smooth = [];
for s = 1:num_spectra
    noise_std = std(collection.Y(1:min_width,s));
    % Find the minimums so we can divide the spectra appropriately
    [maxs,mins,y_smooth] = find_maxs_mins(collection.x,collection.Y(:,s),noise_std); % Find the peak locations
    collection.maxs{s} = maxs;
    collection.mins{s} = mins;
    collection.include_mask{s} = 0*maxs+1; % Include all by default
    collection.BETA{s} = zeros(4*length(maxs),1);
    collection.BETA{s}(4:4:end) = collection.x(maxs);
    collection.Y_smooth(:,s) = y_smooth;
    collection.match_ids{s} = [];
    append_to_log(handles,sprintf('Finished spectrum %d/%d',s,num_spectra));    
end
setappdata(gcf,'collection',collection);

reference = getappdata(gcf,'reference');
noise_std = std(reference.y(1:min_width));
[reference.maxs,reference.mins,reference.y_smooth] = find_maxs_mins(reference.x,reference.y,noise_std); % Find the peak locations
reference.include_mask = 0*reference.maxs + 1;
reference.max_ids = 1:length(reference.maxs);
setappdata(gcf,'reference',reference);
append_to_log(handles,sprintf('Finished reference'));

append_to_log(handles,sprintf('Finished finding peaks'));

refresh_axes1(handles);
refresh_axes2(handles);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mouse = get(gca,'CurrentPoint');
x_click = mouse(1,1);

ButtonName = questdlg('Action?', ...
                      'Reference', ...
                      'Load reference', 'Save reference','Add peak','Add peak');

switch ButtonName,
 case 'Add peak',
    reference = getappdata(gcf,'reference');    
    xwidth = reference.x(1)-reference.x(2);
    new_max = round((reference.x(1)-x_click)/xwidth)+1;
    if ~isfield(reference,'maxs')
        reference.maxs = {};
        reference.mins = {};
        reference.include_mask = [];
    end
    reference.maxs = [reference.maxs,new_max];
    reference.max_ids = [reference.max_ids,0];
    reference.include_mask = [reference.include_mask,0];
    [reference.maxs,inxs] = sort(reference.maxs,'ascend');
    reference.mins = find_mins(reference.y,reference.maxs);
    reference.include_mask = reference.include_mask(inxs);
    reference.max_ids = reference.max_ids(inxs);

%     collection = getappdata(gcf,'collection');
%     [reference,collection] = renumber_matches(reference,collection);
%     setappdata(gcf,'collection',collection);
    setappdata(gcf,'reference',reference);
        
    refresh_axes1(handles);
 case 'Load reference'
    [filename,pathname] = uigetfile('*.mat','Pick a reference');
    if sum(filename ~= 0) > 1
        load([pathname,filename]);
        setappdata(gcf,'reference',reference);
    end
    
    refresh_axes1(handles);
    collection = getappdata(gcf,'collection');
    if isfield(collection,'match_ids')
        collection = rmfield(collection,'match_ids');
    end
    setappdata(gcf,'collection',collection);
    refresh_axes2(handles);
    
    xlim auto
    ylim auto
 case 'Save reference'
    [filename,pathname] = uiputfile('*.mat','Select reference');
    if sum(filename ~= 0) > 1
        reference = getappdata(gcf,'reference');
        save([pathname,filename],'reference');
    end
end % switch


function dirty = isdirty(collection)
try
    dirty = false;
    for s = 1:length(collection.dirty)
        dirty = dirty | collection.dirty(s);
    end
catch ME
    dirty = true;
end

function matched = ismatched(collection)
try
    matched = true;
    for s = 1:length(collection.match_ids)
        if isempty(collection.match_ids{s})
            matched = false;
            return;
        end
    end
catch ME
    matched = false;
end

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mouse = get(gca,'CurrentPoint');
x_click = mouse(1,1);

list = {'Add peak','Set as reference','Visualize deconvolution','View index','Reset y limits','Reset x limits','Set dirty'};
[sel,ok] = listdlg('PromptString','Action:',...
                'SelectionMode','single',...
                'ListString',list);

if ok
    switch list{sel},
     case 'Add peak',
        collection = getappdata(gcf,'collection');    
        s = getappdata(gcf,'s');
        xwidth = collection.x(1)-collection.x(2);
        if ~isfield(collection,'maxs')
            collection.maxs = {};
            nm = size(collection.Y);
            collection.dirty = [];
            for s = 1:length(nm(2))
                collection.maxs{s} = [];
                collection.mins{s} = [];
                collection.match_ids{s} = [];
                collection.include_mask{s} = [];
                collection.BETA{s} = [];
                collection.dirty(s) = true;
            end
        end
        collection.maxs{s} = [collection.maxs{s},round((collection.x(1)-x_click)/xwidth)+1];
        collection.dirty(s) = true;
        collection.include_mask{s} = [collection.include_mask{s},1];
        collection.BETA{s} = [collection.BETA{s};0;0;0;collection.x(collection.maxs{s}(end))];
        if isfield(collection,'match_ids') && ~isempty(collection.match_ids) && ~isempty(collection.match_ids{s})
            collection.match_ids{s} = [collection.match_ids{s},0];
        end
        [collection.maxs{s},inxs] = sort(collection.maxs{s},'ascend');
        collection.mins{s} = find_mins(collection.Y(:,s),collection.maxs{s});
        collection.include_mask{s} = collection.include_mask{s}(inxs);
        collection.BETA{s}(1:4:end) = collection.BETA{s}(4*(inxs-1)+1);
        collection.BETA{s}(2:4:end) = collection.BETA{s}(4*(inxs-1)+2);
        collection.BETA{s}(3:4:end) = collection.BETA{s}(4*(inxs-1)+3);
        collection.BETA{s}(4:4:end) = collection.BETA{s}(4*(inxs-1)+4);
        if isfield(collection,'match_ids') && ~isempty(collection.match_ids) && ~isempty(collection.match_ids{s})
            collection.match_ids{s} = collection.match_ids{s}(inxs);
        end
        setappdata(gcf,'collection',collection);
        
        refresh_axes2(handles);

        update_match_button_Callback([], [], handles);
     case 'Set as reference'
        collection = getappdata(gcf,'collection');    
        s = getappdata(gcf,'s');
        reference = {};
        reference.x = collection.x;
        reference.y = collection.Y(:,s);
        setappdata(gcf,'reference',reference);

        refresh_axes1(handles);

        xlim auto
        ylim auto
     case 'Visualize deconvolution'
        collection = getappdata(gcf,'collection');
        reference = getappdata(gcf,'reference');
        if ~isdirty(collection) && ismatched(collection)
            visualize_deconvolution(collection,reference);
        else
            msgbox('Run deconvolution and match peaks before visualization');
        end
     case 'View index'
        prompt={'Index:'};
        name='Enter an index';
        numlines=1;
        defaultanswer={''};
 
        answer=inputdlg(prompt,name,numlines,defaultanswer);
        try
            collection = getappdata(gcf,'collection');    
            index = str2num(answer{1});
            if index > size(collection.Y,2) || index < 1
                msgbox('Invalid index');
            else
                setappdata(gcf,'s',index);
                refresh_axes2(handles);
            end
            msgbox('View index successful');
        catch ME
            msgbox('Error');
        end
     case 'Reset x limits'
         xlim auto;
     case 'Reset y limits'
         ylim auto;         
     case 'Set dirty'
         setappdata(gcf,'dirty',true);
    end % switch
end

% --- Executes on button press in deconvolution_button.
function deconvolution_button_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolution_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

append_to_log(handles,sprintf('Starting deconvolution'));

collection = getappdata(gcf,'collection');
[num_variables,num_spectra] = size(collection.Y);
if ~isfield(collection,'maxs')
    msgbox('Find peaks before running deconvolution');
    return
end
% First time
if isempty(find(collection.BETA{1}(1:4:end) ~= 0))
    collection.x_baseline_BETA = {};
    collection.baseline_BETA = {};
    collection.y_baseline = {};
    collection.y_fit = {};
    collection.dirty = [];
    collection.dirty(1:length(collection.BETA)) = true;
end
% Perform deconvolution
for s = 1:num_spectra
    x = collection.x;
    xwidth = collection.x(1) - collection.x(2);
    maxs = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;
    if ~getappdata(gcf,'dirty') && ~collection.dirty(s) % Check if anything changed
        append_to_log(handles,sprintf('No deconvolution required for spectrum %d/%d',s,num_spectra));
        continue;
    end
    % A peak has been added
    prev_BETA = collection.BETA{s};
    prev_maxs = maxs;
    if length(maxs) ~= length(collection.maxs{s}) && ~isempty(maxs)
        collection.BETA{s} = []; % Reinitialize
    end
    options = {};
    options.min_width = round(str2num(get(handles.min_width_edit,'String'))/xwidth);
    options.max_width = round(str2num(get(handles.max_width_edit,'String'))/xwidth);
%     % Only optimize those peaks within the current zoom
%     xl = xlim;
    %X = collection.x(collection.maxs{s});
    %m_inxs = find(xl(1) <= X & X <= xl(2));
    if ~isempty(collection.maxs{s})
        results = deconvolve(collection.x',collection.Y(:,s),collection.maxs{s},collection.mins{s},options);

        collection.BETA{s} = results.BETA;
        collection.y_fit{s} = results.y_fit;
        collection.x_baseline_BETA{s} = results.x_baseline_BETA;
        collection.y_baseline{s} = results.y_baseline;
        collection.dirty(s) = false;

        % Update the max indices
        collection.maxs{s} = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;

        append_to_log(handles,sprintf('Finished spectrum %d/%d',s,num_spectra));
    else
        append_to_log(handles,sprintf('No peaks within current zoom for spectrum %d/%d',s,num_spectra));
    end
end
setappdata(gcf,'collection',collection);
setappdata(gcf,'dirty',false);

refresh_axes2(handles);

append_to_log(handles,sprintf('Finished deconvolution'));

% --- Executes on button press in remote_deconvolution.
function remote_deconvolution_Callback(hObject, eventdata, handles)
% hObject    handle to remote_deconvolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

append_to_log(handles,sprintf('Starting deconvolution'));

num_started = 0;
collection = getappdata(gcf,'collection');
[num_variables,num_spectra] = size(collection.Y);
if ~isfield(collection,'maxs')
    msgbox('Find peaks before running deconvolution');
    return
end

% First time
if isempty(find(collection.BETA{1}(1:4:end) ~= 0))
    collection.x_baseline_BETA = {};
    collection.baseline_BETA = {};
    collection.y_baseline = {};
    collection.y_fit = {};
    collection.dirty(1:length(collection.BETA)) = true;
end

collection.file_links = cell(1,num_spectra);
collection.calculate_async_ids = cell(1,num_spectra);
for s = 1:num_spectra
%     x = collection.x;
    xwidth = collection.x(1) - collection.x(2);
%     maxs = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;
    if ~getappdata(gcf,'dirty') && ~collection.dirty(s) % Check if anything changed
        append_to_log(handles,sprintf('No deconvolution required for spectrum %d/%d',s,num_spectra));
        continue;
    end
    num_started = num_started + 1;
%         % A peak has been added
%         if length(maxs) ~= length(collection.maxs{s}) && ~isempty(maxs)
%             collection.BETA{s} = []; % Reinitialize
%         end
    options = {};
    options.min_width = round(str2num(get(handles.min_width_edit,'String'))/xwidth);
    options.max_width = round(str2num(get(handles.max_width_edit,'String'))/xwidth);
    options.num_iterations = round(str2num(get(handles.num_iterations_edit,'String')));
    % Only optimize those peaks within the current zoom
    xl = xlim;
    X = collection.x(collection.maxs{s});
    m_inxs = find(xl(1) <= X & X <= xl(2));
    if ~isempty(m_inxs)
        %create_hadoop_input(collection.x',collection.Y(:,s),collection.maxs{s},collection.mins{s},'hadoop_input.txt',options);
        stdin = create_hadoop_input(collection.x',collection.Y(:,s),collection.maxs{s}(m_inxs),collection.mins{s}(m_inxs,:),[],options);

%         fid = fopen('hadoop_input.txt','r');
%         stdin = char(fread(fid,[1,Inf],'char'));
%         fclose(fid);

        collection.file_links{s} = urlread('http://knoesis1.wright.edu/nmr-service/upload/process_file','post',{'file_as_string',stdin});
        collection.calculate_async_ids{s} = urlread('http://knoesis1.wright.edu/nmr-service/deconvolution/calculate_async','post',{'filename',collection.file_links{s},'mapred.map.tasks','10'});

        append_to_log(handles,sprintf('Started spectrum %d/%d',s,num_spectra));
    else
        append_to_log(handles,sprintf('No peaks in spectrum %d/%d',s,num_spectra));
    end
end
if num_started == 0
    collection = rmfield(collection,'calculate_async_ids');
    collection = rmfield(collection,'file_links');
end
setappdata(gcf,'collection',collection);
% setappdata(gcf,'dirty',false);

% refresh_axes2(handles);

if num_started > 0
    append_to_log(handles,sprintf('Finished starting remote deconvolution. Click check remote deconvolution to process results.'));
else
    append_to_log(handles,sprintf('No deconvolution necessary.'));
end

function log_text_Callback(hObject, eventdata, handles)
% hObject    handle to log_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of log_text as text
%        str2double(get(hObject,'String')) returns contents of log_text as a double


% --- Executes during object creation, after setting all properties.
function log_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to log_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_width_edit as text
%        str2double(get(hObject,'String')) returns contents of min_width_edit as a double

setappdata(gcf,'dirty',true);

% --- Executes during object creation, after setting all properties.
function min_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

setappdata(gcf,'dirty',true);

function max_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to max_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_width_edit as text
%        str2double(get(hObject,'String')) returns contents of max_width_edit as a double

setappdata(gcf,'dirty',true);


% --- Executes during object creation, after setting all properties.
function max_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function num_iterations_edit_Callback(hObject, eventdata, handles)
% hObject    handle to num_iterations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of num_iterations_edit as text
%        str2double(get(hObject,'String')) returns contents of num_iterations_edit as a double

setappdata(gcf,'dirty',true);

% --- Executes during object creation, after setting all properties.
function num_iterations_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to num_iterations_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function baseline_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to baseline_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of baseline_width_edit as text
%        str2double(get(hObject,'String')) returns contents of baseline_width_edit as a double

setappdata(gcf,'dirty',true);

% --- Executes during object creation, after setting all properties.
function baseline_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to baseline_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in match_peaks_button.
function match_peaks_button_Callback(hObject, eventdata, handles)
% hObject    handle to match_peaks_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

append_to_log(handles,'Matching peaks');    

collection = getappdata(gcf,'collection');
reference = getappdata(gcf,'reference');

% Find the best way to divide the spectra up, so that matching can complete
min_split_distance_ppm = str2num(get(handles.min_split_distance_edit,'String'));
peak_locations = reference.x(reference.maxs);
for s = 1:size(collection.Y,2)
    peak_locations = [peak_locations, collection.x(collection.maxs{s})];
end
% Use a window
xl = xlim;
inxs = find(xl(2) >= peak_locations & peak_locations >= xl(1));
peak_locations = peak_locations(inxs);
peak_locations = sort(peak_locations,'descend');
bins = [xl(2),NaN];
for p = 2:length(peak_locations)
    if peak_locations(p-1) - peak_locations(p) >= min_split_distance_ppm
        inxs = find(peak_locations(p-1) > reference.x & reference.x > peak_locations(p));
        [v,i] = min(reference.y(inxs));
        bins(end,2) = reference.x(inxs(i));
        bins(end+1,:) = [bins(end,2) NaN];
    end
end
bins(end,2) = xl(1);

[num_variables,num_spectra] = size(collection.Y);
if ~isfield(collection,'match_ids') || isempty(collection.match_ids)
    collection.match_ids = {};
    for s = 1:num_spectra
        collection.match_ids{s} = zeros(1,length(collection.include_mask{s}));
    end
else
    for s = 1:num_spectra
        if length(collection.match_ids{s}) ~= collection.include_mask{s}
            collection.match_ids{s} = zeros(1,length(collection.include_mask{s}));
        end
    end
end

% Now match each bin separately
[nBins,cols] = size(bins);
% axes(handles.axes2);
% hs = [];
% for b = 1:nBins
%     hs(end+1) = line([bins(b,1),bins(b,1)],ylim);
% end
% delete(hs);
for b = 1:nBins
    left = bins(b,1);
    right = bins(b,2);    
    if ~isfield(collection,'maxs')
        msgbox('Find peaks before trying to match them');
        return
    end
%     if b == 1
%         collection.match_ids = {};
%     end
%     all_dab_bins = {};    
    for s = 1:num_spectra
        x = collection.x;
        maxs = collection.maxs{s};
        bin_inxs = find(left >= x(maxs) & x(maxs) >= right);
        reference_bin_inxs = find(left >= x(reference.maxs) & x(reference.maxs) >= right);
%         if b == 1
%             collection.match_ids{s} = zeros(1,length(collection.include_mask{s}));
%         end
        inxs1 = find(reference.include_mask(reference_bin_inxs) == 1);
        inxs2 = find(collection.include_mask{s}(bin_inxs) == 1);
        
%         dab_collection = {};
%         dab_collection.x = collection.x;
%         dab_collection.Y = collection.Y(:,s);
%         dab_collection.Y(:,2) = reference.y;
%         dab_collection.maxs = {};
%         dab_collection.maxs{1} = collection.maxs{s}(bin_inxs(inxs2));
%         dab_collection.maxs{2} = reference.maxs(reference_bin_inxs(inxs1));
%         max_dist_btw_maxs_ppm = 0.04;
%         min_dist_from_boundary_ppm = 0;
%         dab_bins = dynamic_adaptive_bin(dab_collection,max_dist_btw_maxs_ppm,min_dist_from_boundary_ppm);
%         all_dab_bins{s} = dab_bins;
%         for dab_b = 1:size(dab_bins,1)
%             % First make all of the reference peaks in the bin have the same
%             % id
%             x_values = reference.x(reference.maxs(reference_bin_inxs(inxs1)));
%             dab_bin_inxs = find(dab_bins(dab_b,1) > x_values & x_values >= dab_bins(dab_b,2));
%             if ~isempty(dab_bin_inxs)
%                 id = reference.max_ids(reference_bin_inxs(dab_bin_inxs(1))); % Default to the first label
%                 reference.max_ids(reference_bin_inxs(inxs1(dab_bin_inxs))) = id;
%             end
%         end
                
%         [match_ids,final_score] = match_peaks_dynamic(x(reference.maxs(reference_bin_inxs(inxs1))),...
%             x(maxs(bin_inxs(inxs2))),str2num(get(handles.search_width_edit,'String')));
        
%         match_ids = match_peaks_R2(x(reference.maxs(reference_bin_inxs(inxs1))),...
%             x(maxs(bin_inxs(inxs2))),str2num(get(handles.search_width_edit,'String')),...
%             collection.x(1)-collection.x(2),str2num(get(handles.min_split_distance_edit,'String')),str2num(get(handles.search_sigma_edit,'String')));

        max_distance = 20;
        answer_maxs = x(reference.maxs(reference_bin_inxs(inxs1)));
        calc_maxs = x(maxs(bin_inxs(inxs2)));
        [match_ids,final_score] = match_peaks_dynamic(answer_maxs,calc_maxs,max_distance);

         for i = 1:length(match_ids)
             if match_ids{i}(1) ~= 0 && match_ids{i}(2) ~= 0 % Nothing to match in axes2
                 collection.match_ids{s}(bin_inxs(inxs2(match_ids{i}(2)))) = reference.max_ids(reference_bin_inxs(inxs1(match_ids{i}(1))));
             end
         end
    end
%     for s = 1:num_spectra
%         dab_bins = all_dab_bins{s};
%         maxs = collection.maxs{s};
%         bin_inxs = find(left >= x(maxs) & x(maxs) >= right);
%         inxs2 = find(collection.include_mask{s}(bin_inxs) == 1);
%         for dab_b = 1:size(dab_bins,1)
%             % Make sure they all have the same id, which they should at
%             % this point
%             x_values = reference.x(reference.maxs(reference_bin_inxs(inxs1)));
%             dab_bin_inxs = find(dab_bins(dab_b,1) >= x_values & x_values >= dab_bins(dab_b,2));
%             if ~isempty(dab_bin_inxs)
%                 id = reference.max_ids(reference_bin_inxs(dab_bin_inxs(1))); % Default to the first label
%             else
%                 id = 0;
%             end
%             x_values = collection.x(collection.maxs{s}(bin_inxs(inxs2)));
%             dab_bin_inxs = find(dab_bins(dab_b,1) >= x_values & x_values >= dab_bins(dab_b,2));
%             collection.match_ids{s}(bin_inxs(inxs2(dab_bin_inxs))) = id;
%         end
%     end

    append_to_log(handles,sprintf('Finished segment %d/%d',b,nBins));    
end
[reference,collection] = renumber_matches(reference,collection);
setappdata(gcf,'reference',reference);
setappdata(gcf,'collection',collection);

append_to_log(handles,'Finished matching peaks');

refresh_axes1(handles);
refresh_axes2(handles);


% --- Executes on button press in update_match_button.
function update_match_button_Callback(hObject, eventdata, handles)
% hObject    handle to update_match_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

update_match(handles);
reference = getappdata(gcf,'reference');
collection = getappdata(gcf,'collection');
[reference,collection] = renumber_matches(reference,collection);
setappdata(gcf,'collection',collection);
setappdata(gcf,'reference',reference);
refresh_axes1(handles);
refresh_axes2(handles);

% --- Executes on button press in save_collection_button.
function save_collection_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_collection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = getappdata(gcf,'collection');
reference = getappdata(gcf,'reference');
if isfield(collection,'BETA')
    collection = quantify(collection,reference);
    save_collections({collection},'_deconvolution');
else
    msgbox('Run deconvolution');
end

% --- Executes on button press in post_collection_button.
function post_collection_button_Callback(hObject, eventdata, handles)
% hObject    handle to post_collection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = getappdata(gcf,'collection');
reference = getappdata(gcf,'reference');
prompt={'Analysis ID:'};
name='Enter the analysis ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
analysis_id = answer{1};        
collection = quantify(collection,reference);
post_collections({collection},'_deconvolution',analysis_id);  


function search_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to search_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_width_edit as text
%        str2double(get(hObject,'String')) returns contents of search_width_edit as a double


% --- Executes during object creation, after setting all properties.
function search_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_remote_deconvolution.
function check_remote_deconvolution_Callback(hObject, eventdata, handles)
% hObject    handle to check_remote_deconvolution (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

append_to_log(handles,sprintf('Checking deconvolution'));

collection = getappdata(gcf,'collection');
num_not_finished = 0;
if ~isfield(collection,'calculate_async_ids')
    msgbox('No remote deconvolution to check');
    return;
end
x = collection.x;
xwidth = x(1)-x(2);
[num_variables,num_spectra] = size(collection.Y);
xl = xlim;
for s = 1:num_spectra
    if isempty(collection.calculate_async_ids{s})
        continue;
    end

    status_result = urlread('http://knoesis1.wright.edu/nmr-service/deconvolution/status','post',{'token',collection.calculate_async_ids{s}});
    if ~isempty(regexp(status_result,'In_progress','match'))
        append_to_log(handles,sprintf('Still remotely processing spectrum %d/%d (%s)',s,num_spectra,collection.calculate_async_ids{s}));
        num_not_finished = num_not_finished + 1;
    else
        % A peak has been added
        prev_BETA = collection.BETA{s};
        maxs = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;
        prev_maxs = maxs;
        if length(maxs) ~= length(collection.maxs{s}) && ~isempty(maxs)
            collection.BETA{s} = []; % Reinitialize
        end

        split_status_result = split(status_result,sprintf('\n'));
        mapper_output = urlread(split_status_result{end},'get',{});

        if ~isempty(regexp(status_result,'Job not Successful','match')) % Restart
            append_to_log(handles,sprintf('Job not successful spectrum %d/%d (%s)',s,num_spectra,collection.calculate_async_ids{s}));
            collection = rmfield(collection,'calculate_async_ids');
            collection = rmfield(collection,'file_links');
            setappdata(gcf,'collection',collection);
            msgbox('Deconvolution failed. Try again');
            return;
        end

        options = {};
        options.baseline_width = str2num(get(handles.baseline_width_edit,'String'));
        options.min_width = round(str2num(get(handles.min_width_edit,'String'))/xwidth);
        options.max_width = round(str2num(get(handles.max_width_edit,'String'))/xwidth);
        options.num_generations = 100;
        %results = reducer(collection.x',collection.Y(:,s),mapper_output,options);
        o_inxs = find(collection.x(prev_maxs) < xl(1) | collection.x(prev_maxs) > xl(2)); % Find only those outside of the region
        o_prev_BETA = [];
        for q = 1:length(o_inxs)
            o_prev_BETA = [o_prev_BETA;prev_BETA(4*(o_inxs(q)-1)+(1:4))];
        end
        results = reducer(collection.x',collection.Y(:,s),mapper_output,o_prev_BETA,collection.x(prev_maxs(o_inxs)),options);
        collection.BETA{s} = results.BETA;
        collection.y_fit{s} = results.solution.y_fit;
        collection.x_baseline_BETA{s} = results.x_baseline_BETA;
%             collection.baseline_BETA{s} = results.baseline_BETA;
        collection.y_baseline{s} = results.y_baseline;

        % Update the max indices            
        collection.maxs{s} = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;
        collection.dirty(s) = false;

        append_to_log(handles,sprintf('Finished spectrum %d/%d (%s)',s,num_spectra,collection.calculate_async_ids{s}));
        collection.calculate_async_ids{s} = [];
        collection.file_links{s} = [];
    end
end
if num_not_finished == 0
    setappdata(gcf,'dirty',false);
    collection = rmfield(collection,'calculate_async_ids');
    collection = rmfield(collection,'file_links');
    setappdata(gcf,'collection',collection);
    refresh_axes2(handles);
    append_to_log(handles,sprintf('All remote deconvolution finished.'));
else
    setappdata(gcf,'collection',collection);
end

append_to_log(handles,sprintf('Finished checking remote deconvolution.'));


% --- Executes on button press in apply_regions_pushbutton.
function apply_regions_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to apply_regions_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

valid_regions = get_valid_regions(handles);

collection = getappdata(gcf,'collection');
[num_regions, tmp] = size(valid_regions);
[num_variables,num_spectra] = size(collection.Y);
for s = 1:num_spectra
    maxs = collection.maxs{s};
%     mins = collection.mins{s};
    % Check to see if maxs are in regions
    X = collection.x(maxs);
    for j = 1:num_regions
        inxs = find(valid_regions(j,1) >= X & X >= valid_regions(j,2));
        X(inxs) = NaN;
    end
%     ixs = find(~isnan(X));
%     collection.maxs{s} = maxs(ixs);
%     collection.mins{s} = mins(ixs,:);
%     collection.include_mask{s} = 0*maxs(ixs)+1; % Include all by default
     ixs = find(~isnan(X));
     collection.include_mask{s}(ixs) = 0;
     if num_regions == 0
         collection.include_mask{s}(:) = 1;
     end
end

reference = getappdata(gcf,'reference');
maxs = reference.maxs;
% mins = reference.mins;
% Check to see if maxs are in regions
X = reference.x(maxs);
for j = 1:num_regions
    inxs = find(valid_regions(j,1) >= X & X >= valid_regions(j,2));
    X(inxs) = NaN;
end
ixs = find(~isnan(X));
reference.include_mask(ixs) = 0;
if num_regions == 0
    reference.include_mask(:) = 1;
end
% ixs = find(~isnan(X));
% reference.maxs = maxs(ixs);
% reference.mins = mins(ixs,:);
% reference.include_mask = 0*maxs(ixs)+1; % Include all by default

setappdata(gcf,'collection',collection);
setappdata(gcf,'reference',reference);

values = {};
for j = 1:num_regions
    values{j} = sprintf('%0.4f,%0.4f',valid_regions(j,1),valid_regions(j,2));
end
set(handles.regions_listbox,'String',values);

setappdata(gcf,'dirty',true);

refresh_axes1(handles);
refresh_axes2(handles);


function min_split_distance_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_split_distance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_split_distance_edit as text
%        str2double(get(hObject,'String')) returns contents of min_split_distance_edit as a double


% --- Executes during object creation, after setting all properties.
function min_split_distance_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_split_distance_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_dist_from_boundary_ppm_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_dist_from_boundary_ppm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_dist_from_boundary_ppm_edit as text
%        str2double(get(hObject,'String')) returns contents of min_dist_from_boundary_ppm_edit as a double


% --- Executes during object creation, after setting all properties.
function min_dist_from_boundary_ppm_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_dist_from_boundary_ppm_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_figure_pushbutton.
function save_figure_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_figure_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uiputfile('*.fig', 'Save figure');
try
    if strcmp(filename,'main.fig')
        msgbox('Cannot overwrite main.fig. Pick another name and another directory.');
        return;
    end
    saveas(gcf,[pathname,filename]);
catch ME
end

function valid_regions = get_valid_regions(handles)
% Get the regions to include
regions_str = get(handles.regions_edit,'String');
[num_regions,tmp] = size(regions_str);
valid_regions = [];
for i = 1:num_regions
    try
        if sum(regions_str(i,:) == ' ') == length(regions_str(i,:))
            continue;
        end
        region_str = split(regions_str(i,:),',');
        region = [str2num(region_str{1}),str2num(region_str{2})];            
        if region(1) < region(2)
            tmp = region(1);
            region(1) = region(2);
            region(2) = tmp;
        end
        valid_regions(end+1,1) = region(1);
        valid_regions(end,2) = region(2);
    catch ME
         fprintf('Warning: Failed when processing [%s]\n',regions_str(i,:));
    end
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in reference_peaks_listbox.
function reference_peaks_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to reference_peaks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns reference_peaks_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from reference_peaks_listbox

contents = cellstr(get(hObject,'String'));
x_loc_str = contents{get(hObject,'Value')};
if isempty(x_loc_str)
    return;
end
masked = false;
if x_loc_str(1) == '*'
    x_loc_str = x_loc_str(2:end);
    masked = true;
end

if ~masked
    reference_peak_inx = 1;
    for i = 2:length(contents)
        if strcmp(contents{i},x_loc_str)
            break;
        end
        if contents{i}(1) ~= '*'
            reference_peak_inx = reference_peak_inx + 1;
        end
    end
end
x_loc = str2num(x_loc_str);
collection = getappdata(gcf,'collection');
width = str2num(get(handles.window_width_edit,'String'));
min_x = x_loc-width/2;
max_x = x_loc+width/2;
if isfield(collection,'match_ids') && length(collection.match_ids) == size(collection.Y,2) && ~masked
    for s = 1:size(collection.Y,2)
        inxs = find(collection.match_ids{s} == reference_peak_inx);
        for z = 1:length(inxs);
            inx = inxs(z);
            s_x_loc = collection.x(collection.maxs{s}(inx));
            if min_x > s_x_loc-width/2
                min_x = s_x_loc-width/2;
            end
            if max_x < s_x_loc+width/2
                max_x = s_x_loc+width/2;
            end
        end
    end
end

axes(handles.axes1);
xlim([min_x,max_x]);
ylim auto;

set(handles.spectrum_peaks_listbox,'Value',1);


% --- Executes during object creation, after setting all properties.
function reference_peaks_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to reference_peaks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in spectrum_peaks_listbox.
function spectrum_peaks_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to spectrum_peaks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns spectrum_peaks_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from spectrum_peaks_listbox

contents = cellstr(get(hObject,'String'));
x_loc_str = contents{get(hObject,'Value')};
if isempty(x_loc_str)
    return;
end
if x_loc_str(1) == '*'
    x_loc_str = x_loc_str(2:end);
end

x_loc = str2num(x_loc_str);
width = str2num(get(handles.window_width_edit,'String'));
min_x = x_loc-width/2;
max_x = x_loc+width/2;

axes(handles.axes2);
xlim([min_x,max_x]);
ylim auto;

set(handles.reference_peaks_listbox,'Value',1);

% --- Executes during object creation, after setting all properties.
function spectrum_peaks_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spectrum_peaks_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function window_width_edit_Callback(hObject, eventdata, handles)
% hObject    handle to window_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of window_width_edit as text
%        str2double(get(hObject,'String')) returns contents of window_width_edit as a double


% --- Executes during object creation, after setting all properties.
function window_width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function search_sigma_edit_Callback(hObject, eventdata, handles)
% hObject    handle to search_sigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of search_sigma_edit as text
%        str2double(get(hObject,'String')) returns contents of search_sigma_edit as a double


% --- Executes during object creation, after setting all properties.
function search_sigma_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to search_sigma_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_match_pushbutton.
function save_match_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_match_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = getappdata(gcf,'collection');
reference = getappdata(gcf,'reference');
[filename, pathname] = uiputfile('*.csv', 'Save match as');
f = fopen([pathname,filename],'w');
fprintf(f,join(reference.x(reference.maxs),','));
fprintf(f,'\n');
fprintf(f,join(reference.max_ids,','));
fprintf(f,'\n');
for s = 1:collection.num_samples
    x_maxs = collection.x(collection.maxs{s});
    fprintf(f,join(x_maxs,','));
    fprintf(f,'\n');
    fprintf(f,join(collection.match_ids{s},','));
    fprintf(f,'\n');
end
fclose(f);


% --- Executes on button press in hide_legend_checkbox.
function hide_legend_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to hide_legend_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide_legend_checkbox

axis2_legend = getappdata(gcf,'axis2_legend');
if isempty(axis2_legend)
    return;
end

if get(handles.hide_legend_checkbox,'Value')
    set(axis2_legend,'Visible','off');
else
    set(axis2_legend,'Visible','on');
end



% --- Executes on selection change in regions_listbox.
function regions_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to regions_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regions_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regions_listbox
contents = cellstr(get(hObject,'String'));
item = contents{get(hObject,'Value')};
fields = split(item,',');
region = [str2num(fields{1}),str2num(fields{2})];
axes(handles.axes2);
if region(1) < region(2)
    xlim([region(1),region(2)]);
else
    xlim([region(2),region(1)]);
end
ylim auto;

% --- Executes during object creation, after setting all properties.
function regions_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regions_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in regions_uitable.
function regions_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to regions_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.regions_uitable,'data');
row = eventdata.Indices(1);
col = eventdata.Indices(1);
left = data{row,1};
right = data{row,2};
if isnumeric(left) && isnumeric(right)
    if left > right
        xlim([right,left]);
    else
        xlim([left,right]);
    end
end
    

% --- Executes when entered data in editable cell(s) in regions_uitable.
function regions_uitable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to regions_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



function regions_edit_Callback(hObject, eventdata, handles)
% hObject    handle to regions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of regions_edit as text
%        str2double(get(hObject,'String')) returns contents of regions_edit as a double


% --- Executes during object creation, after setting all properties.
function regions_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regions_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in regions_listbox.
function listbox9_Callback(hObject, eventdata, handles)
% hObject    handle to regions_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns regions_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from regions_listbox


% --- Executes during object creation, after setting all properties.
function listbox9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to regions_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in hide_peak_numbers_checkbox.
function hide_peak_numbers_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to hide_peak_numbers_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of hide_peak_numbers_checkbox
hlabels = [findobj('Tag','axes1_hlabels');findobj('Tag','axes2_hlabels')];
if get(handles.hide_peak_numbers_checkbox,'Value')
    set(hlabels,'Visible','off');
else
    set(hlabels,'Visible','on');
end

hmaxs = [findobj('Tag','axes1_hmaxs');findobj('Tag','axes2_hmaxs')];
if get(handles.hide_peak_numbers_checkbox,'Value')
    set(hmaxs,'Visible','off');
else
    set(hmaxs,'Visible','on');
end
