function varargout = visualize_deconvolution(varargin)
% visualize_deconvolution M-file for visualize_deconvolution.fig
%      visualize_deconvolution, by itself, creates a new visualize_deconvolution or raises the existing
%      singleton*.
%
%      H = visualize_deconvolution returns the handle to a new visualize_deconvolution or the handle to
%      the existing singleton*.
%
%      visualize_deconvolution('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in visualize_deconvolution.M with the given input arguments.
%
%      visualize_deconvolution('Property','Value',...) creates a new visualize_deconvolution or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before visualize_deconvolution_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to visualize_deconvolution_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help visualize_deconvolution

% Last Modified by GUIDE v2.5 04-Apr-2011 14:57:51

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @visualize_deconvolution_OpeningFcn, ...
                   'gui_OutputFcn',  @visualize_deconvolution_OutputFcn, ...
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


% --- Executes just before visualize_deconvolution is made visible.
function visualize_deconvolution_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to visualize_deconvolution (see VARARGIN)

% Choose default command line output for visualize_deconvolution
handles.output = hObject;

handles.collection = varargin{1};
handles.reference = varargin{2};

data = {};
cnt = 1;
if isfield(handles.reference,'maxs')
    for i = 1:length(handles.reference.maxs)
        if handles.reference.include_mask(i)
            data{cnt,1} = handles.reference.max_ids(i);
            data{cnt,2} = handles.reference.x(handles.reference.maxs(i));
            data{cnt,3} = NaN; % P
            data{cnt,4} = NaN; % abs(P)
            data{cnt,5} = ''; % Significant>
            cnt = cnt + 1;
        end
    end
else
    msgbox('Please find the peaks in the reference and perform a deconvolution before running this program');
    return;
end

set(handles.loadings_uitable,'data',data);
set(handles.loadings_uitable,'ColumnName',{'ID','x (ppm)','P','abs(P)','Sig?'});

clear_all(hObject,handles);

set(handles.description_text,'String',handles.collection.description);


% Update handles structure
guidata(hObject, handles);

% UIWAIT makes visualize_deconvolution wait for user response (see UIRESUME)
% uiwait(handles.visualize_deconvolution_figure);


% --- Outputs from this function are returned to the command line.
function varargout = visualize_deconvolution_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



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

group_by_time_pushbutton(hObject,handles);

% --- Executes on button press in group_by_classification_pushbutton.
function group_by_classification_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_classification_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

group_by_classification_pushbutton(hObject,handles);

% --- Executes on button press in group_by_time_and_classification_pushbutton.
function group_by_time_and_classification_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to group_by_time_and_classification_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

group_by_time_and_classification_pushbutton(hObject,handles);

% --- Executes on button press in run_pushbutton.
function run_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to run_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

clear_before_run(hObject,handles);

% Get the data
try
    collection = handles.collection;
catch ME
    msgbox('No collection loaded');
    return;
end
try
    group_by_inxs = handles.group_by_inxs;
    selected = get(handles.group_by_listbox,'Value');
    group_by_inxs = {group_by_inxs{selected}};
    handles.run_group_by_inxs = group_by_inxs;
catch ME
    msgbox('Select groups');
    return;
end

num_samples = 0;
for i = 1:length(group_by_inxs)
    num_samples = num_samples + length(group_by_inxs{i});
end
[num_variables,total_num_samples] = size(collection.Y);
   
available_Y = NaN*ones(1,total_num_samples);
available_X = NaN*ones(num_variables,total_num_samples);
Y = [];%NaN*ones(1,num_samples);
X = [];%NaN*ones(num_variables,num_samples);
s = 0;
for g = 1:length(group_by_inxs)    
    for i = 1:length(group_by_inxs{g})
        inx_unpaired = group_by_inxs{g}(i);
        s = s + 1;
        X(:,s) = collection.Y(:,inx_unpaired);
        Y(s) = g;
    end
end
% Now grab all that is available
for g = 1:length(handles.group_by_inxs)
    for i = 1:length(handles.group_by_inxs{g})
        inx_unpaired = handles.group_by_inxs{g}(i);
        s = s + 1;
        available_X(:,inx_unpaired) = collection.Y(:,inx_unpaired);
        available_Y(inx_unpaired) = g;
    end
end

contents = get(handles.group_by_listbox,'String');
available_groups = get(handles.group_by_listbox,'String');
groups = {contents{get(handles.group_by_listbox,'Value')}};

%% Spectra plot
show_raw = get(handles.show_raw_checkbox,'Value');
axes(handles.spectra_axes);
load('colors');
hs = [];
hold on
if show_raw
    for g = 1:length(handles.run_group_by_inxs)
        for i = 1:length(handles.run_group_by_inxs{g})
            inx = handles.run_group_by_inxs{g}(i);
            h = plot(collection.x,available_X(:,inx),...
                'Marker','none','Color',...
                colors{mod(g-1,length(colors))+1},...
                'MarkerFaceColor',colors{mod(g-1,length(colors))+1});
            myfunc = @(hObject, eventdata, handles) (line_click_info(collection,inx));
            set(h,'ButtonDownFcn',myfunc);
            menu = uicontextmenu('Callback',myfunc);
            set(h,'UIContextMenu',menu);                
            if i == 1
                hs(end+1) = h;
            end
        end
    end
    hold off
    legend(hs,groups,'Location','Best');
end
set(gca,'xdir','reverse');
xlabel('x (ppm)','Interpreter','tex');
ylabel('Intensity','Interpreter','tex');

% Save a few things for later
data = {};
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
handles.available_Y = available_Y';
handles.available_X = available_X';
handles.available_groups = available_groups;
handles.X = X';
handles.Y = Y';

if isfield(handles,'eventdata')
    loadings_uitable_CellSelectionCallback(handles.loadings_uitable, handles.eventdata, handles);
end

msgbox('Finished');

% Update handles structure
guidata(hObject, handles);

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

try
    collection = handles.collection;
catch ME
    msgbox('No collection loaded');
    return;
end
reference_peak_inx = getappdata(gcf,'reference_peak_inx');

figure;
rows = str2num(get(handles.scores_rows_edit,'String'));
columns = str2num(get(handles.scores_columns_edit,'String'));
data = get(handles.scores_uitable,'data');
legends = {};
h_groups = {};
hide_legends = {};
group_inxs = {};
d = 0;
show_raw = get(handles.show_raw_checkbox,'Value');
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
        subplot_inx = str2num(subplot_inxs{z});
        subplot(rows,columns,subplot_inx);
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
                if ~isempty(reference_peak_inx)
                    s = inxs(i);
                    pinxs = find(collection.match_ids{s} == reference_peak_inx);
                    for q = 1:length(pinxs)
                        inx = pinxs(q);
                        BETA = collection.BETA{s}(4*(inx-1)+(1:4));
                        h = line(collection.x,one_peak_model(BETA,collection.x),'Color',data{d,3},'LineWidth',2);
                        myfunc = @(hObject, eventdata, handles) (line_click_info(collection,s));
                        set(h,'ButtonDownFcn',myfunc);
                        if i == 1
                            h_groups{subplot_inx}(end+1) = h;
                        end
                    end
                end
                if show_raw
                    h = plot(collection.x,handles.available_X(inxs(i),:),...
                        'Marker',data{d,4},'Color',data{d,3},...
                        'MarkerFaceColor',data{d,3});
                    myfunc = @(hObject, eventdata, handles) (line_click_info(collection,inxs(i)));
                    set(h,'ButtonDownFcn',myfunc);
                    if i == 1 && isempty(reference_peak_inx)
                        h_groups{subplot_inx}(end+1) = h;
                    end
                end
            end                                
        else
            for i = 1:length(inxs)
                h = plot(collection.x,handles.available_X(inxs(i),:),...
                    'Marker',data{d,4},'Color',data{d,3});
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
% xlim_values = [];
% ylim_values = [];
% xlim_str = get(handles.xlim_edit,'String');
% ylim_str = get(handles.ylim_edit,'String');
% if ~isempty(xlim_str)
%     xlim_fields = split(xlim_str,',');
%     xlim_values = [str2num(xlim_fields{1}),str2num(xlim_fields{2})];
% end
% if ~isempty(ylim_str)
%     ylim_fields = split(ylim_str,',');
%     ylim_values = [str2num(ylim_fields{1}),str2num(ylim_fields{2})];
% end
i = 1;
for r = 1:rows
    for c = 1:columns
        subplot(rows,columns,i);
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
%         if ~isempty(xlim_values)
%             xlim(xlim_values);
%         end
%         if ~isempty(xlim_values)
%             xlim(xlim_values);
%         end
%         if ~isempty(ylim_values)
%             ylim(ylim_values);            
%         end
    end
end


% --- Executes on button press in load_bins_pushbutton.
function load_bins_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_bins_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.txt', 'Pick a bin file');
fid = fopen([pathname,filename],'r');
line = fgetl(fid);
fclose(fid);
data = get(handles.loadings_uitable,'data');
centers = cell2mat({data{:,1}});
fields = split(line,';');
max_error_match = 0.001; % ppm
for i = 1:length(fields)
    left_right = split(fields{i},',');
    left = str2num(left_right{1});
    right = str2num(left_right{2});
    center = (left+right)/2;
    matched = false;
    for j = 1:length(centers)
        if abs(center-centers(j)) < max_error_match
            data{j,5} = left;
            data{j,6} = right;
            matched = true;
            break;
        end
    end
    if ~matched
        fprintf('%f not matched\n',center);
    end
end
set(handles.loadings_uitable,'data',data);



% --- Executes when selected cell(s) is changed in loadings_uitable.
function loadings_uitable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to loadings_uitable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

delete(findobj('Tag','visualize_deconvolution_hpeaks')); % Delete previous peaks

if ~isempty(eventdata.Indices)
    collection = handles.collection;
    data = get(handles.loadings_uitable,'data');
    row_inx = eventdata.Indices(1,1);
    reference_peak_inx = data{row_inx,1};
    center = data{row_inx,2};
    width = str2num(get(handles.window_width_edit,'String'));
    min_x = center-width/2;
    max_x = center+width/2;
    load('colors');
    if isfield(handles,'run_group_by_inxs')
        for g = 1:length(handles.run_group_by_inxs)
            for i = 1:length(handles.run_group_by_inxs{g})
                s = handles.run_group_by_inxs{g}(i);
                inxs = find(collection.match_ids{s} == reference_peak_inx);
                for z = 1:length(inxs)
                    inx = inxs(z);
                    BETA = collection.BETA{s}(4*(inx-1)+(1:4));
                    if min_x > BETA(4)-width/2
                        min_x = BETA(4)-width/2;
                    end
                    if max_x < BETA(4)+width/2
                        max_x = BETA(4)+width/2;
                    end
                    h = line(collection.x,one_peak_model(BETA,collection.x),'Color',colors{mod(g-1,length(colors))+1},'Tag','visualize_deconvolution_hpeaks','LineWidth',2);
                    myfunc = @(hObject, eventdata, handles) (line_click_info(collection,s));
                    set(h,'ButtonDownFcn',myfunc);
                    menu = uicontextmenu('Callback',myfunc);
                    set(h,'UIContextMenu',menu);                
                end
            end
        end
    end
    handles.xlim = [min_x,max_x];
    xlim(handles.xlim);
    ylim auto;
    handles.eventdata = eventdata;
    setappdata(gcf,'reference_peak_inx',reference_peak_inx);

    guidata(hObject, handles);
else
    setappdata(gcf,'reference_peak_inx',[]);
end


% --- Executes on button press in save_figure_pushbutton.
function save_figure_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to save_figure_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename,pathname] = uiputfile('*.fig', 'Save figure');
try
    if strcmp(filename,'visualize_deconvolution.fig')
        msgbox('Cannot overwrite visualize_deconvolution.fig. Pick another name and another directory.');
        return;
    end
    saveas(gcf,[pathname,filename]);
catch ME
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


% --- Executes during object creation, after setting all properties.
function visualize_deconvolution_figure_CreateFcn(hObject, eventdata, handles)
% hObject    handle to visualize_deconvolution_figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function clear_before_run(hObject,handles)

axes(handles.spectra_axes);
h = plot(0,0);
delete(h);

function clear_all(hObject,handles)
set(handles.group_by_listbox,'String','');
try
    rmfield(handles,'group_by_inxs');
catch ME
end

clear_before_run(hObject,handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in show_raw_checkbox.
function show_raw_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_raw_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_raw_checkbox


% --- Executes on button press in show_peaks_checkbox.
function show_peaks_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to show_peaks_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of show_peaks_checkbox


% --- Executes on button press in load_loadings_pushbutton.
function load_loadings_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to load_loadings_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

try
    [filename, pathname] = uigetfile('*.xlsx', 'Pick an OPLS loadings file');
    [NUMERIC,TXT,RAW] = xlsread([pathname,filename],'Loadings');
    x_inx = find(strcmp({TXT{1,:}},'x'));
    p_inx = find(strcmp({TXT{1,:}},'P'));
    s_inx = find(strcmp({TXT{1,:}},'Significant?'));
    x = NUMERIC(:,x_inx);
    p = NUMERIC(:,p_inx);
    s = NUMERIC(:,s_inx);
    data=get(handles.loadings_uitable,'data');
    max_error_match = 0;
    for i = 1:length(x)
        matched = false;
        for j = 1:size(data)
            if abs(x(i)-data{j,1}) <= max_error_match
                data{j,3} = p(i);
                data{j,4} = abs(p(i));
                if s(i)
                    data{j,5} = true;
                else
                    data{j,5} = false;
                end
                matched = true;
                break;
            end
        end
        if ~matched
            fprintf('i: %d, id: %d not matched\n',i,x(i));
        end
    end
    set(handles.loadings_uitable,'data',data);

catch ME
    msgbox('Invalid loadings');
end


% --- Executes on button press in x_zoom_out_pushbutton.
function x_zoom_out_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to x_zoom_out_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buf = str2num(get(handles.x_zoom_edit,'String'));
xl = xlim;
xlim([xl(1)-buf,xl(2)+buf]);
ylim auto;

% --- Executes on button press in zoom_in_pushbutton.
function zoom_in_pushbutton_Callback(hObject, eventdata, handles)
% hObject    handle to zoom_in_pushbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

buf = str2num(get(handles.x_zoom_edit,'String'));
xl = xlim;
xlim([xl(1)+buf,xl(2)-buf]);
ylim auto;

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
