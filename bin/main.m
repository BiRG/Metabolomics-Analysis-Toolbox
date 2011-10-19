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

% Last Modified by GUIDE v2.5 05-Oct-2011 14:03:16

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

set(handles.version_text,'String',get_version_string());

% myfunc = @(hObject, eventdata, handles_) (key_press(handles));
% set(gcf,'KeyPressFcn',myfunc);

set(handles.collection_uipanel,'Visible','on');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','off');
set(handles.deconvolution_uipanel,'Visible','off');

data = cell(1,1);
data{1} = '';
set(handles.bins_listbox,'String',data);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function res = get_version_string()
res = '0r1';

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

handles = get_collection_pushbutton(handles);

set(handles.noise_region_edit,'String',sprintf('%.3f,%.3f',handles.collection.x(1),handles.collection.x(30)));

ymax = max(handles.collection.Y(:,1));
ymin = min(handles.collection.Y(:,1));
handles.ymax = ymax;
handles.ymin = ymin;
set(handles.y_zoom_edit,'String',sprintf('%f',(ymax-ymin)*.005));

populate_listboxes(handles);

msgbox('Finished loading collection');

% Update handles structure
guidata(hObject, handles);

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


% --- Executes on button press in run_pushbutton.
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
        data{end,9} = false;% Hide Orig
        data{end,10} = true;% Hide fit
        data{end,11} = true;% Hide baseline and peaks
        data{end,12} = true;% Hide residual
        data{end,13} = false;% Hide peaks
    end
end
set(handles.scores_uitable,'data',data);
handles.available_groups = available_groups;

% Now update plot
axes(handles.spectra_axes);
plot_spectra(handles,true);

% Update handles structure
guidata(handles.figure1, handles);

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

figure;
plot_spectra(handles,false);

function plot_spectra(handles,disable_subplot_feature)

try
    collection = handles.collection;
catch ME
    msgbox('No collection loaded');
    throw(ME);
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
to_make_invisible = [];
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
%                 myfunc = @(hObject, eventdata, handles_) (line_click_info(collection,inxs(i)));
                if data{d,9}
                    to_make_invisible(end+1) = h;
                end
                setappdata(h,'inx',inxs(i));
                set(h,'ButtonDownFcn',@line_click_info_myfunc);
                if i == 1
                    h_groups{subplot_inx}(end+1) = h;
                end
            end                                
        else
            for i = 1:length(inxs)
                h = plot(collection.x,handles.available_X(inxs(i),:),...
                    'Marker',data{d,4},'Color',data{d,3},'tag','spectrum_line');
                if data{d,9}
                    set(h,'visible','no'); % Hide the original data
                end
                setappdata(h,'inx',inxs(i));
%                 myfunc = @(hObject, eventdata, handles_) (line_click_info(collection,inxs(i)));
                set(h,'ButtonDownFcn',@line_click_info_myfunc);
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

plot_maxs(handles,disable_subplot_feature);

if ~isempty(to_make_invisible)
    set(to_make_invisible,'visible','off');
end

function line_click_info_myfunc(hObject,eventdata)
mouse = get(gca,'CurrentPoint');
x_click = mouse(1,1);

s = getappdata(hObject,'inx');
handles = guidata(hObject);

ButtonName = questdlg('Select action', ...
                      'Action', ...
                      'View Spectrum Information', 'Add Peak', 'View Spectrum Information');
switch (ButtonName),
     case 'Add Peak',
        collection = handles.collection;
        xwidth = collection.x(1)-collection.x(2);
        if ~isfield(collection,'maxs')
            collection.maxs = {};
            nm = size(collection.Y);
            collection.dirty = [];
            for s = 1:length(nm(2))
                collection.maxs{s} = [];
                collection.mins{s} = [];
                collection.include_mask{s} = [];
                collection.regions{s} = {};
                collection.dirty(s) = true;
            end
        end
        collection.maxs{s} = [collection.maxs{s},round((collection.x(1)-x_click)/xwidth)+1];
        collection.include_mask{s} = [collection.include_mask{s},1];
        [collection.maxs{s},inxs] = sort(collection.maxs{s},'ascend');
        collection.mins{s} = find_mins(collection.Y(:,s),collection.maxs{s});
        collection.include_mask{s} = collection.include_mask{s}(inxs);
        
        % Update
        handles.collection = collection;
        guidata(hObject,handles);
        
        plot_maxs(handles,true);
        
    case 'View Spectrum Information',
        line_click_info(handles.collection,s);
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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

[username,password] = logindlg;

file = tempname;
saveas(handles.figure1,[file,'.fig']);

prompt={'Analysis ID:','Description:','File name:'};
name='Input for uploading file';
numlines=1;
defaultanswer={'','Binning results','binning_results'};
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

handles = load_collection_pushbutton(handles);

set(handles.noise_region_edit,'String',sprintf('%.3f,%.3f',handles.collection.x(1),handles.collection.x(30)));

ymax = max(handles.collection.Y(:,1));
ymin = min(handles.collection.Y(:,1));
handles.ymax = ymax;
handles.ymin = ymin;
set(handles.y_zoom_edit,'String',sprintf('%f',(ymax-ymin)*.005));

populate_listboxes(handles);

msgbox('Finished loading collection');

% Update handles structure
guidata(hObject, handles);

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

% --- Executes on button press in save_bins_pushbutton.
function save_bins_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_bins_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

[regions,deconvolve] = get_bins(handles);
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
    fprintf(file,'\n');
    for b = 1:length(lefts)
        if b > 1
            fprintf(file,';');
        end
        if deconvolve(b)
            fprintf(file,'deconvolve');
        else
            fprintf(file,'sum');
        end
    end
    fclose(file);
end

% --- Executes on button press in load_bins_pushbutton.
function load_bins_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_bins_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

collection = handles.collection;
[bins,deconvolve] = get_bins(handles);
% Remove adjacent deconvolution
Y = adjust_y_deconvolution(collection,bins,deconvolve);
collection.Y = Y;
new_collection = bin_collection(collection,bins,get(handles.autoscale_checkbox,'Value'),handles.collection.Y);
save_collections({new_collection},'_binned');

% --- Executes on button press in post_collection_pushbutton.
function post_collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to post_collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

collection = handles.collection;
[bins,deconvolve] = get_bins(handles);
prompt={'Analysis ID:'};
name='Enter the analysis ID from the website';
numlines=1;
defaultanswer={''};
answer=inputdlg(prompt,name,numlines,defaultanswer);
analysis_id = answer{1};        
Y = adjust_y_deconvolution(collection,bins,deconvolve);
collection.Y = Y;
new_collection = bin_collection(collection,bins,get(handles.autoscale_checkbox,'Value'),handles.collection.Y);
post_collections(gcf,{new_collection},'_binned',analysis_id);

% --- Executes on button press in add_bin_pushbutton.
function add_bin_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to add_bin_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

sort_bins(handles);

function sort_bins(handles)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

[bins,deconvolve] = get_bins(handles);
[bins,inxs] = sortrows(bins,1);
deconvolve = deconvolve(inxs);

data = cell(size(bins,1)+1,1);
for b = 1:size(bins,1)
    if deconvolve(b)
        data{b} = sprintf('%f,%f,Deconvolve',bins(b,1),bins(b,2));
    else
        data{b} = sprintf('%f,%f',bins(b,1),bins(b,2));
    end
end
data{end} = '';

set(handles.bins_listbox,'String',data(end:-1:1));
set(handles.bins_listbox,'Value',1);

% xlim auto;
% ylim auto;

guidata(handles.figure1, handles);

% --- Executes on button press in delete_pushbutton.
function delete_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to delete_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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

[bins,deconvolve] = get_bins(handles);
data = {};
data{1} = '';
for b = 1:size(bins,1)
    if bin_inx-1 ~= b
        data = add_bin_to_data(data,bins,deconvolve,b);
    end
end
set(handles.bins_listbox,'String',data);
set(handles.bins_listbox,'Value',1);

delete_cursors();

guidata(hObject, handles);

% inxs = find(handles.xlim(1) <= handles.collection.x & handles.collection.x <= handles.xlim(2));
% ylim([min(min(handles.X(:,inxs)')),max(max(handles.X(:,inxs)'))]);

function data = add_bin_to_data(data,bins,deconvolve,b)
if deconvolve(b)
    data{end+1} = sprintf('%f,%f,Deconvolve',bins(b,1),bins(b,2));
else
    data{end+1} = sprintf('%f,%f',bins(b,1),bins(b,2));
end


% --- Executes on button press in zoom_out_pushbutton.
function zoom_out_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_out_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

[filename,pathname] = uiputfile('*.fig', 'Save figure');
try
    if strcmp(filename,'main.fig')
        msgbox('Cannot overwrite main.fig. Pick another name and another directory.');
        return;
    end
    saveas(handles.figure1,[pathname,filename]);
catch ME
    throw(ME);
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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

buf = str2num(get(handles.x_zoom_edit,'String'));
xl = xlim;
xlim([xl(1)-buf,xl(2)+buf]);
% ylim auto;

% --- Executes on button press in x_zoom_in_pushbutton.
function x_zoom_in_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to x_zoom_in_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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

if get(handles.lock_window_checkbox,'Value')
    x_range = handles.x_range;
    current_x_range = handles.xlim(2) - handles.xlim(1);
    diff = x_range - current_x_range;
    handles.xlim = [handles.xlim(1)-diff/2,handles.xlim(2)+diff/2];
end

xlim(handles.xlim);
ylim auto;
    
yl = ylim;
bins = get_bins(handles);
for b = 1:size(bins,1)
    color = 'm';
    if mod(b-1,2) == 0
        color = 'b';
    end
    right_cursor = create_cursor(bins(b,2),[handles.ymin,handles.ymax],color,b,handles);
    set(right_cursor,'LineWidth',3);
    set(right_cursor,'LineStyle','--');
    %myfunc = @(hObject, eventdata) (click_bin_boundary(b,right_cursor,handles));
    %set(right_cursor,'ButtonDownFcn',myfunc);
    
    set(right_cursor,'tag','right_cursor');
    left_cursor = create_cursor(bins(b,1),[handles.ymin,handles.ymax],color,b,handles);
    set(left_cursor,'LineWidth',3);
    set(left_cursor,'tag','left_cursor');           
%     myfunc = @(hObject, eventdata) (click_bin_boundary(b,left_cursor,handles));
%     set(left_cursor,'ButtonDownFcn',myfunc);    
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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

buf = str2num(get(handles.y_zoom_edit,'String'));
yl = ylim;
ylim([yl(1),yl(2)+buf]);

% --- Executes on button press in y_zoom_in_pushbutton.
function y_zoom_in_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to y_zoom_in_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

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
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

set(handles.collection_uipanel,'Visible','off');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','on');
set(handles.deconvolution_uipanel,'Visible','off');

% --- Executes on button press in results_pushbutton.
function results_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to results_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

set(handles.collection_uipanel,'Visible','off');
set(handles.results_uipanel,'Visible','on');
set(handles.dab_uipanel,'Visible','off');
set(handles.deconvolution_uipanel,'Visible','off');

% --- Executes on button press in collection_pushbutton.
function collection_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to collection_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

set(handles.collection_uipanel,'Visible','on');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','off');
set(handles.deconvolution_uipanel,'Visible','off');


% --- Executes on button press in update_plot_pushbutton.
function update_plot_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to update_plot_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

% Now update plot
axes(handles.spectra_axes);
plot_spectra(handles,true);



% --- Executes on button press in lock_window_checkbox.
function lock_window_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to lock_window_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of lock_window_checkbox
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

xl = xlim;
handles.x_range = xl(2)-xl(1);

guidata(hObject, handles);


% --- Executes on button press in left_pushbutton.
function left_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to left_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

xlim1 = xlim;
xdist = str2num(get(handles.x_zoom_edit,'String'));
xlim([xlim1(1)+xdist,xlim1(2)+xdist]); 
    
% --- Executes on button press in right_pushbutton.
function right_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to right_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

xlim1 = xlim;
xdist = str2num(get(handles.x_zoom_edit,'String'));
xlim([xlim1(1)-xdist,xlim1(2)-xdist]);        


% --- Executes on button press in open_figure_pushbutton.
function open_figure_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to open_figure_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uigetfile('*.fig', 'Open figure');
open([pathname,filename]);


% --- Executes on button press in about_pushbutton.
function about_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to about_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

web('about.html'); 


% --- Executes on button press in deconvolve_pushbutton.
function deconvolve_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolve_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
add_line_to_summary_text(handles.summary_text,sprintf('Starting deconvolution'));

[num_variables,num_spectra] = size(handles.collection.Y);
handles = get_peaks(handles);
collection = handles.collection;

collection.y_baseline = {};
collection.y_fit = {};

% Perform deconvolution
for s = 1:num_spectra
    if ~isempty(collection.maxs{s})
        [bins,deconvolve_mask] = get_bins(handles);
        results = deconvolve2(collection.x',collection.Y(:,s),collection.maxs{s},collection.mins{s},bins,deconvolve_mask,1,2);
        %results = deconvolve2(collection.x',collection.Y(:,s),collection.maxs{s},collection.mins{s},bins,deconvolve_mask,options);

        collection.regions{s} = results.regions;
        collection.y_fit{s} = results.y_fit;
        collection.y_baseline{s} = results.y_baseline;

        % Update the max indices
        %collection.maxs{s} = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;
        % I've disconnected maxs and BETA

        add_line_to_summary_text(handles.summary_text,sprintf('Finished spectrum %d/%d',s,num_spectra));
    else
        add_line_to_summary_text(handles.summary_text,sprintf('No peaks within current zoom for spectrum %d/%d',s,num_spectra));
    end
end
handles.collection = collection;

% setappdata(gcf,'dirty',false);

add_line_to_summary_text(handles.summary_text,sprintf('Finished deconvolution'));

msgbox('Finished Deconvolution');

guidata(hObject, handles);

% --- Executes on button press in deconvolution_pushbutton.
function deconvolution_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolution_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

set(handles.collection_uipanel,'Visible','off');
set(handles.results_uipanel,'Visible','off');
set(handles.dab_uipanel,'Visible','off');
set(handles.deconvolution_uipanel,'Visible','on');


% --- Executes on mouse press over axes background.
function spectra_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to spectra_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

mouse = get(gca,'CurrentPoint');
x_click = mouse(1,1);

list = {'Reset y limits','Reset x limits'};
[sel,ok] = listdlg('PromptString','Action:',...
                'SelectionMode','single',...
                'ListString',list);

if ok
    switch list{sel},
     case 'Reset x limits'
         xlim auto;
     case 'Reset y limits'
         ylim auto;         
    end % switch
end


% --- Executes on selection change in group_by_fields_listbox.
function group_by_fields_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_fields_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns group_by_fields_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from group_by_fields_listbox
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

handles = group_by_fields_listbox(hObject,handles);

update_spectra_plot(handles)

% --- Executes during object creation, after setting all properties.
function group_by_fields_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to group_by_fields_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in model_by_fields_listbox.
function model_by_fields_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to model_by_fields_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns model_by_fields_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from model_by_fields_listbox
[result,message] = validate_state(handles,get_version_string());
if ~result
    msgbox(message);
    return;
end

model_by_fields_listbox(hObject,handles);

% --- Executes during object creation, after setting all properties.
function model_by_fields_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_by_fields_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function populate_listboxes(handles)
flds = fields(handles.collection);
valid_flds = {};
for i = 1:length(flds)
    [rows,cols] = size(handles.collection.(flds{i}));
    if rows == 1 && cols == handles.collection.num_samples
        valid_flds{end+1} = flds{i};
    end
end
sorted_valid_flds = sort(valid_flds);

set(handles.model_by_fields_listbox,'String',{'',sorted_valid_flds{:}});
set(handles.model_by_fields_listbox,'Max',length({'',sorted_valid_flds{:}}));

set(handles.group_by_fields_listbox,'String',{'',sorted_valid_flds{:}});
set(handles.group_by_fields_listbox,'Max',length({'',sorted_valid_flds{:}}));
