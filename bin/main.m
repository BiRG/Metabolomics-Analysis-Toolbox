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

% Last Modified by GUIDE v2.5 25-Apr-2011 15:14:29

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

set(handles.summary_text,'String',{''});

myfunc = @(hObject, eventdata, handles_) (key_press(handles));
set(gcf,'KeyPressFcn',myfunc);

set(handles.collection_uipanel,'Visible','on');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','off');

data = cell(1,1);
data{1} = '';
set(handles.bins_listbox,'String',data);


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



function collection_id_edit_Callback(hObject, eventdata, handles)
% hObject    handle to collection_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of collection_id_edit as text
%        str2double(get(hObject,'String')) returns contents of collection_id_edit as a double


% --- Executes during object creation, after setting all properties.
function collection_id_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to collection_id_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in get_collection_button.
function get_collection_button_Callback(hObject, eventdata, handles)
% hObject    handle to get_collection_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    collection_id = str2num(get(handles.collection_id_edit,'String'));
    handles.collection = get_collection(collection_id);
    set(handles.noise_region_edit,'String',sprintf('%.3f,%.3f',handles.collection.x(1),handles.collection.x(30)));
    
    clear_all(hObject,handles);

    set(handles.description_text,'String',handles.collection.description);
    
    ymax = max(handles.collection.Y(:,1));
    ymin = min(handles.collection.Y(:,1));
    handles.ymax = ymax;
    handles.ymin = ymin;
    set(handles.y_zoom_edit,'String',sprintf('%f',(ymax-ymin)*.005));
    
    msgbox('Finished loading collection');
    
    % Update handles structure
    guidata(hObject, handles);
catch ME
    msgbox('Invalid collection ID');
end


% --- Executes on selection change in group_by_listbox.
function group_by_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns group_by_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from group_by_listbox


% --- Executes during object creation, after setting all properties.
function group_by_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group_by_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in group_by_time_pushbutton.
function group_by_time_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_time_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = group_by_time_pushbutton(hObject,handles);
update_spectra_plot(handles);

% --- Executes on button press in group_by_classification_pushbutton.
function group_by_classification_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_classification_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = group_by_classification_pushbutton(hObject,handles);
update_spectra_plot(handles);

% --- Executes on button press in group_by_time_and_classification_pushbutton.
function group_by_time_and_classification_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_time_and_classification_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles = group_by_time_and_classification_pushbutton(hObject,handles);
update_spectra_plot(handles);

% --- Executes on button press in run_pushbutton.
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear_before_run(hObject,handles);

peak_finding_options = {};
peak_finding_options.level = str2num(get(handles.level_edit,'String'));
contents = get(handles.tptr_listbox,'String');
peak_finding_options.tptr = contents{get(handles.tptr_listbox,'Value')};
contents = get(handles.sorh_listbox,'String');
peak_finding_options.sorh = contents{get(handles.sorh_listbox,'Value')};
contents = get(handles.scal_listbox,'String');
peak_finding_options.scal = contents{get(handles.scal_listbox,'Value')};
contents = get(handles.wavelet_listbox,'String');
peak_finding_options.wavelet = contents{get(handles.wavelet_listbox,'Value')};
peak_finding_options.noise_std_mult = str2num(get(handles.noise_std_edit,'String'));

noise_region_str = get(handles.noise_region_edit,'String');
fields = split(noise_region_str,',');
left = str2num(fields{1});
right = str2num(fields{2});
if left < right
    temp = left;
    left = right;
    right = temp;
end
max_dist_btw_maxs_ppm = str2num(get(handles.max_dist_btw_peaks_edit,'String'));
min_dist_from_boundary_ppm = str2num(get(handles.min_dist_peak_to_boundary_edit,'String'));

[X,Y] = get_run_data(hObject,handles);
if isempty(X) || isempty(Y)
    msgbox('No model data available');
    return;
end

bins = dynamic_adaptive_bin(handles.collection.x',X,left,right,...
    max_dist_btw_maxs_ppm,min_dist_from_boundary_ppm,peak_finding_options);
data = cell(size(bins,1)+1,1);
data{1} = '';
for b = 1:size(bins,1)
    data{b+1} = sprintf('%f,%f',bins(b,1),bins(b,2));
end

set(handles.bins_listbox,'String',data);

handles.X = X';
handles.Y = Y';

set(handles.bins_listbox,'Value',1);
msgbox('Finished running DAB');

% Update handles structure
guidata(hObject, handles);

function update_spectra_plot(handles)
if ~isfield(handles,'collection')
    msgbox('No collection loaded');
    return;
end

[X,Y,available_X,available_Y] = get_run_data(handles.figure1,handles);
handles.available_X = available_X';
handles.available_Y = available_Y';

% %% Spectra plot
% contents = get(handles.model_by_listbox,'String');
% groups = {contents{get(handles.model_by_listbox,'Value')}};
% axes(handles.spectra_axes);
% load('colors');
% hs = [];
% hold on
% for g = 1:length(groups)
%     inxs = find(Y == g);
%     for i = 1:length(inxs)
%         h = plot(handles.collection.x,X(:,inxs(i)),...
%             'Marker','none','Color',...
%             colors{mod(g-1,length(colors))+1},...
%             'MarkerFaceColor',colors{mod(g-1,length(colors))+1});
%         if i == 1
%             hs(end+1) = h;
%         end
%     end
% end
% hold off
% set(gca,'xdir','reverse');
% legend(hs,groups,'Location','Best');
% xlabel('x (ppm)','Interpreter','tex');
% % ylabel('Intensity','Interpreter','tex');

% Save a few things for later
available_groups = get(handles.group_by_listbox,'String');
data = {};
load('colors');
for g = 1:length(handles.group_by_inxs)
    if ~isempty(find(available_Y == g)) % Make sure we have data
        data{end+1,1} = available_groups{g}; % Group
        data{end,2} = '1'; % Subplot
        data{end,3} = colors{mod(g-1,length(colors)-2)+1}; % -2 because the last two colors are vectors
        data{end,4} = 'none';
        data{end,5} = true; % Fill
        data{end,6} = available_groups{g}; % Legend
        data{end,7} = true; % Include
        data{end,8} = false;% Hide Legend
    end
end
set(handles.scores_uitable,'data',data);
handles.available_groups = available_groups;

% Now update plot
axes(handles.spectra_axes);
plot_spectra(handles,true);

% Update handles structure
guidata(handles.figure1, handles);

function add_line_to_summary_text(h,line)
current = get(h,'String');
current = {line,current{:}};
set(h,'String',current);


function scores_columns_edit_Callback(hObject, eventdata, handles)
% hObject    handle to scores_columns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scores_columns_edit as text
%        str2double(get(hObject,'String')) returns contents of scores_columns_edit as a double


% --- Executes during object creation, after setting all properties.
function scores_columns_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scores_columns_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scores_rows_edit_Callback(hObject, eventdata, handles)
% hObject    handle to scores_rows_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scores_rows_edit as text
%        str2double(get(hObject,'String')) returns contents of scores_rows_edit as a double


% --- Executes during object creation, after setting all properties.
function scores_rows_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scores_rows_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in plot_pushbutton.
function plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

figure;
plot_spectra(handles,false);

function plot_spectra(handles,disable_subplot_feature)

try
    collection = handles.collection;
catch ME
    msgbox('No collection loaded');
    throw(ME);
    return;
end

h = findobj(gcf,'tag','spectrum_line');
delete(h);

rows = str2num(get(handles.scores_rows_edit,'String'));
columns = str2num(get(handles.scores_columns_edit,'String'));
if disable_subplot_feature
    rows = 1;
    columns = 1;
end
data = get(handles.scores_uitable,'data');
legends = {};
h_groups = {};
hide_legends = {};
group_inxs = {};
d = 0;
for g = 1:length(handles.group_by_inxs)
    inxs = find(handles.available_Y == g);
    if isempty(inxs)
        continue;
    end
    d = d + 1;
    group_inxs{end+1} = handles.group_by_inxs{g};
    if ~data{d,7} % Don't include
        continue;
    end
    
    subplot_inxs = split(data{d,2},',');
    for z = 1:length(subplot_inxs)
        if disable_subplot_feature
            subplot_inx = 1;
        else
            subplot_inx = str2num(subplot_inxs{z});
            subplot(rows,columns,subplot_inx);
        end
        if subplot_inx > length(legends)
            legends{subplot_inx} = {};
            h_groups{subplot_inx} = [];
            hide_legends{subplot_inx} = [];
        end
        legends{subplot_inx}{end+1} = data{d,6};
        hide_legends{subplot_inx}(end+1) = data{d,8};
        hold on
        fill = data{d,5};        
        if fill
            for i = 1:length(inxs)
                h = plot(collection.x,handles.available_X(inxs(i),:),...
                    'Marker',data{d,4},'Color',data{d,3},...
                    'MarkerFaceColor',data{d,3},'tag','spectrum_line');
                myfunc = @(hObject, eventdata, handles) (line_click_info(collection,inxs(i)));
                set(h,'ButtonDownFcn',myfunc);
                if i == 1
                    h_groups{subplot_inx}(end+1) = h;
                end
            end                                
        else
            for i = 1:length(inxs)
                h = plot(collection.x,handles.available_X(inxs(i),:),...
                    'Marker',data{d,4},'Color',data{d,3},'tag','spectrum_line');
                myfunc = @(hObject, eventdata, handles) (line_click_info(collection,inxs(i)));
                set(h,'ButtonDownFcn',myfunc);
                if i == 1
                    h_groups{subplot_inx}(end+1) = h;
                end
            end
        end
        hold off
    end
end
for i = 1:rows*columns
    if length(legends) < i
        legends{i} = {};
        h_groups{i} = [];
        hide_legends{i} = [];
    end
end

% Go through subplots and fix legends
i = 1;
for r = 1:rows
    for c = 1:columns
        if ~disable_subplot_feature
            subplot(rows,columns,i);
        end
        set(gca,'xdir','reverse');
        selected_legends = {};
        selected_h_groups = [];
        for j = 1:length(legends{i})
            if ~hide_legends{i}(j)
                selected_legends{end+1} = legends{i}{j};
                selected_h_groups(end+1) = h_groups{i}(j);
            end
        end
        if ~isempty(selected_legends)
            [vs,inxs] = sort(selected_legends);
            legend(selected_h_groups(inxs),{selected_legends{inxs}});
        end
        i = i + 1;
        if c == 1
            ylabel('Intensity','Interpreter','tex');
        end
        if r == rows
            xlabel('Chemical shift (ppm)','Interpreter','tex');
        end
        if isfield(handles,'xlim')
            xlim(handles.xlim);
        end
    end
end


function xlim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to xlim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xlim_edit as text
%        str2double(get(hObject,'String')) returns contents of xlim_edit as a double


% --- Executes during object creation, after setting all properties.
function xlim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xlim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ylim_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ylim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ylim_edit as text
%        str2double(get(hObject,'String')) returns contents of ylim_edit as a double


% --- Executes during object creation, after setting all properties.
function ylim_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ylim_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in post_to_analysis_pushbutton.
function post_to_analysis_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to post_to_analysis_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

username = [];
password = [];
if isempty(username) || isempty(password)
    [username,password] = logindlg;
end

file = tempname;
saveas(handles.figure1,[file,'.fig']);

prompt={'Analysis ID:','Description:','File name:'};
name='Input for uploading file';
numlines=1;
defaultanswer={'','DAB results','dab_results'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
analysis_id = answer{1};
description = answer{2};
pretty_file_name = answer{3};

f = fopen([file,'.fig']); 
d = fread(f,Inf,'*uint8'); % Read in byte stream
fclose(f); 
str = urlreadpost('http://birg.cs.wright.edu/omics_analysis/saved_files', ... 
        {'data',d,'name',username,'password',password,'analysis_id',analysis_id,'description',description,'pretty_file_name',pretty_file_name});
fprintf(str);

% --- Executes on button press in load_collection_pushbutton.
function load_collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    collections = load_collections;
    if isempty(collections)
        return
    end
    if length(collections) > 1
        msgbox('Only load a single collection');
        return;
    end
    handles.collection = collections{1};
    set(handles.noise_region_edit,'String',sprintf('%.3f,%.3f',handles.collection.x(1),handles.collection.x(30)));
    
    clear_all(hObject,handles);
    
    set(handles.description_text,'String',handles.collection.description);
    
    ymax = max(handles.collection.Y(:,1));
    ymin = min(handles.collection.Y(:,1));
    handles.ymax = ymax;
    handles.ymin = ymin;
    set(handles.y_zoom_edit,'String',sprintf('%f',(ymax-ymin)*.005));

    msgbox('Finished loading collection');
    
    % Update handles structure
    guidata(hObject, handles);
catch ME
    msgbox('Invalid collection');
    throw(ME);
end

% --- Executes on selection change in model_by_listbox.
function model_by_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to model_by_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns model_by_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from model_by_listbox


% --- Executes during object creation, after setting all properties.
function model_by_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_by_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in model_by_time_pushbutton.
function model_by_time_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to model_by_time_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

model_by_time_pushbutton(hObject,handles);

% --- Executes on button press in model_by_classification_pushbutton.
function model_by_classification_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to model_by_classification_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

model_by_classification_pushbutton(hObject,handles);

% --- Executes on button press in model_by_time_and_classification_pushbutton.
function model_by_time_and_classification_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to model_by_time_and_classification_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

model_by_time_and_classification_pushbutton(hObject,handles);


% --- Executes on selection change in tptr_listbox.
function tptr_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to tptr_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tptr_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tptr_listbox


% --- Executes during object creation, after setting all properties.
function tptr_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tptr_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in sorh_listbox.
function sorh_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to sorh_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns sorh_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from sorh_listbox


% --- Executes during object creation, after setting all properties.
function sorh_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sorh_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in scal_listbox.
function scal_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to scal_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns scal_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from scal_listbox


% --- Executes during object creation, after setting all properties.
function scal_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scal_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function level_edit_Callback(hObject, eventdata, handles)
% hObject    handle to level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of level_edit as text
%        str2double(get(hObject,'String')) returns contents of level_edit as a double


% --- Executes during object creation, after setting all properties.
function level_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to level_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_std_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_std_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_std_edit as a double


% --- Executes during object creation, after setting all properties.
function noise_std_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_std_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in wavelet_listbox.
function wavelet_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to wavelet_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns wavelet_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from wavelet_listbox


% --- Executes during object creation, after setting all properties.
function wavelet_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to wavelet_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_region_edit_Callback(hObject, eventdata, handles)
% hObject    handle to noise_region_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_region_edit as text
%        str2double(get(hObject,'String')) returns contents of noise_region_edit as a double


% --- Executes during object creation, after setting all properties.
function noise_region_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noise_region_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function max_dist_btw_peaks_edit_Callback(hObject, eventdata, handles)
% hObject    handle to max_dist_btw_peaks_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of max_dist_btw_peaks_edit as text
%        str2double(get(hObject,'String')) returns contents of max_dist_btw_peaks_edit as a double


% --- Executes during object creation, after setting all properties.
function max_dist_btw_peaks_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to max_dist_btw_peaks_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function min_dist_peak_to_boundary_edit_Callback(hObject, eventdata, handles)
% hObject    handle to min_dist_peak_to_boundary_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of min_dist_peak_to_boundary_edit as text
%        str2double(get(hObject,'String')) returns contents of min_dist_peak_to_boundary_edit as a double


% --- Executes during object creation, after setting all properties.
function min_dist_peak_to_boundary_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to min_dist_peak_to_boundary_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function bins = get_bins(handles)
bins = [];
data = get(handles.bins_listbox,'String');
for b = 2:size(data,1) % Skip the first blank
    fields = split(data{b},',');    
    bins(end+1,:) = [str2num(fields{1}),str2num(fields{2})];
end

% --- Executes on button press in save_bins_pushbutton.
function save_bins_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_bins_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

regions = get_bins(handles);
lefts = regions(:,1);
rights = regions(:,2);
[filename,pathname] = uiputfile('*.txt', 'Save regions');
file = fopen([pathname,filename],'w');
if file > 0
    for b = 1:length(lefts)
        if b > 1
            fprintf(file,';');
        end
        fprintf(file,'%f,%f',lefts(b),rights(b));
    end
    fclose(file);
end

% --- Executes on button press in load_bins_pushbutton.
function load_bins_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_bins_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uigetfile('*.txt', 'Load regions');
file = fopen([pathname,filename],'r');
myline = fgetl(file);
regions = split(myline,';');
lefts = [];
rights = [];
for i = 1:length(regions)
    region = regions{i};
    fields = split(region,',');
    lefts(end+1) = str2num(fields{1});
    rights(end+1) = str2num(fields{2});
end
regions = zeros(length(lefts),2);
regions(:,1) = lefts';
regions(:,2) = rights';

data = cell(size(regions,1)+1,1);
data{1} = '';
for b = 1:size(regions,1)
    data{b+1} = sprintf('%f,%f',regions(b,1),regions(b,2));
end

set(handles.bins_listbox,'String',data);
set(handles.bins_listbox,'Value',1);

xlim auto;
ylim auto;

% --- Executes on button press in save_collection_pushbutton.
function save_collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = handles.collection;
bins = get_bins(handles);
new_collection = bin_collection(collection,bins,get(handles.autoscale_checkbox,'Value'),handles.X');
save_collections({new_collection},'_binned');

% --- Executes on button press in post_collection_pushbutton.
function post_collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to post_collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

collection = handles.collection;
bins = get_bins(handles);
prompt={'Analysis ID:'};
name='Enter the analysis ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
analysis_id = answer{1};        
new_collection = bin_collection(collection,bins,get(handles.autoscale_checkbox,'Value'),handles.X');
post_collections(main_h,{new_collection},'_binned',analysis_id);

% --- Executes on button press in add_bin_pushbutton.
function add_bin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to add_bin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xl = xlim;
data = get(handles.bins_listbox,'String');
data{end+1} = sprintf('%f,%f',xl(2),xl(1));
set(handles.bins_listbox,'String',data);
delete_cursors();

% --- Executes on button press in sort_pushbutton.
function sort_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to sort_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

sort_bins(handles);

function sort_bins(handles)

bins = get_bins(handles);
bins = sortrows(bins,1);

data = cell(size(bins,1)+1,1);
for b = 1:size(bins,1)
    data{b} = sprintf('%f,%f',bins(b,1),bins(b,2));
end
data{end} = '';

set(handles.bins_listbox,'String',data(end:-1:1));
set(handles.bins_listbox,'Value',1);

xlim auto;
ylim auto;

delete_cursors();

guidata(handles.figure1, handles);

% --- Executes on button press in delete_pushbutton.
function delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if get(handles.delete_all_checkbox,'Value')
    data = {};
    data{1} = '';
    set(handles.bins_listbox,'String',data);
    set(handles.bins_listbox,'Value',1);
    guidata(hObject, handles);
    return;
end

bin_inx = get(handles.bins_listbox,'Value');
if bin_inx == 1
    return;
end

bins = get_bins(handles);
data = {};
data{1} = '';
for b = 1:size(bins,1)
    if bin_inx-1 ~= b
        data{end+1} = sprintf('%f,%f',bins(b,1),bins(b,2));
    end
end
set(handles.bins_listbox,'String',data);
set(handles.bins_listbox,'Value',1);

delete_cursors();

guidata(hObject, handles);

% inxs = find(handles.xlim(1) <= handles.collection.x & handles.collection.x <= handles.xlim(2));
% ylim([min(min(handles.X(:,inxs)')),max(max(handles.X(:,inxs)'))]);

% --- Executes on button press in zoom_out_pushbutton.
function zoom_out_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

xlim auto;
ylim auto;


% --- Executes on button press in autoscale_checkbox.
function autoscale_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to autoscale_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoscale_checkbox


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

function delete_cursors()
h = findobj(gcf,'tag','right_cursor');
delete(h);
h = findobj(gcf,'tag','left_cursor');
delete(h);

% --- Executes on button press in x_zoom_out_pushbutton.
function x_zoom_out_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to x_zoom_out_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buf = str2num(get(handles.x_zoom_edit,'String'));
xl = xlim;
xlim([xl(1)-buf,xl(2)+buf]);
% ylim auto;

% --- Executes on button press in x_zoom_in_pushbutton.
function x_zoom_in_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to x_zoom_in_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buf = str2num(get(handles.x_zoom_edit,'String'));
xl = xlim;
xlim([xl(1)+buf,xl(2)-buf]);
% ylim auto;

function x_zoom_edit_Callback(hObject, eventdata, handles)
% hObject    handle to x_zoom_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of x_zoom_edit as text
%        str2double(get(hObject,'String')) returns contents of x_zoom_edit as a double


% --- Executes during object creation, after setting all properties.
function x_zoom_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_zoom_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in bins_listbox.
function bins_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns bins_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from bins_listbox

delete_cursors;

contents = cellstr(get(hObject,'String'));
bin_inx = get(hObject,'Value')-1;
bin_str = contents{bin_inx+1};
if strcmp(bin_str,'');
    xlim auto;
    ylim auto;
    return;
end

fields = split(bin_str,',');
bin = [str2num(fields{1}),str2num(fields{2})];
inverted_bin = false;
buf = str2num(get(handles.x_zoom_edit,'String'));
if bin(1) < bin(2)
    inverted_bin = true;
    handles.xlim = [bin(1)-buf,bin(2)+buf];
else
    handles.xlim = [bin(2)-buf,bin(1)+buf];
end
    
if ~get(handles.lock_window_checkbox,'Value')
    xlim(handles.xlim);
    ylim auto
end

yl = ylim;
bins = get_bins(handles);
for b = 1:size(bins,1)
    right_cursor = create_cursor(bins(b,2),[handles.ymin,handles.ymax],'r');
    if b == bin_inx
        set(right_cursor,'LineWidth',3);
    end
    set(right_cursor,'tag','right_cursor');
    left_cursor = create_cursor(bins(b,1),[handles.ymin,handles.ymax],'g');
    if b == bin_inx
        set(left_cursor,'LineWidth',3);
    end
    set(left_cursor,'tag','left_cursor');           
end

if inverted_bin
    msgbox(sprintf('Inverted bin: %f,%f',bin(1),bin(2)));    
end

ylim(yl);
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function bins_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bins_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in debug_pushbutton.
function debug_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to debug_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

add_line_to_summary_text(handles.summary_text,'Debugging...');
bins = get_bins(handles);
for b = 1:size(bins,1)
    if bins(b,1) < bins(b,2)
        add_line_to_summary_text(handles.summary_text,sprintf('Inverted bin boundaries: %f,%f',bins(b,1),bins(b,2)));
    end
end
add_line_to_summary_text(handles.summary_text,'Finished debugging');

% --- Executes on button press in update_bins_pushbutton.
function update_bins_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to update_bins_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

bins = get_bins(handles);
% bin_inx = get(handles.bins_listbox,'Value')-1;
% if bin_inx == 0
%     return;
% end
left_cursors = findobj(gcf,'tag','left_cursor'); % Order isn't guranteed
right_cursors = findobj(gcf,'tag','right_cursor');
if isempty(left_cursors) || isempty(right_cursors)
    return;
end
for b = 1:size(bins,1)
    left = get_cursor_location(left_cursors(b));
    right = get_cursor_location(right_cursors(b));
    bins(b,:) = [left,right];
end

data = cell(size(bins,1)+1,1);
data{1} = '';
for b = 1:size(bins,1)
    data{b+1} = sprintf('%f,%f',bins(b,1),bins(b,2));
end

set(handles.bins_listbox,'String',data);

sort_bins(handles);


% --- Executes on button press in delete_all_checkbox.
function delete_all_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to delete_all_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of delete_all_checkbox


% --- Executes on button press in y_zoom_out_pushbutton.
function y_zoom_out_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to y_zoom_out_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buf = str2num(get(handles.y_zoom_edit,'String'));
yl = ylim;
ylim([yl(1),yl(2)+buf]);

% --- Executes on button press in y_zoom_in_pushbutton.
function y_zoom_in_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to y_zoom_in_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buf = str2num(get(handles.y_zoom_edit,'String'));
yl = ylim;
ylim([yl(1),yl(2)-buf]);

function y_zoom_edit_Callback(hObject, eventdata, handles)
% hObject    handle to y_zoom_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of y_zoom_edit as text
%        str2double(get(hObject,'String')) returns contents of y_zoom_edit as a double


% --- Executes during object creation, after setting all properties.
function y_zoom_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_zoom_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function summary_text_Callback(hObject, eventdata, handles)
% hObject    handle to summary_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of summary_text as text
%        str2double(get(hObject,'String')) returns contents of summary_text as a double


% --- Executes during object creation, after setting all properties.
function summary_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to summary_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in dab_pushbutton.
function dab_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to dab_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.collection_uipanel,'Visible','off');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','on');

% --- Executes on button press in results_pushbutton.
function results_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to results_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.collection_uipanel,'Visible','off');
set(handles.results_uipanel,'Visible','on');
set(handles.dab_uipanel,'Visible','off');

% --- Executes on button press in collection_pushbutton.
function collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.collection_uipanel,'Visible','on');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','off');


% --- Executes on button press in update_plot_pushbutton.
function update_plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to update_plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Now update plot
axes(handles.spectra_axes);
plot_spectra(handles,true);



% --- Executes on button press in lock_window_checkbox.
function lock_window_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to lock_window_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lock_window_checkbox


