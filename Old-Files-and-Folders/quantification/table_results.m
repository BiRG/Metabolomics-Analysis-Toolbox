function varargout = table_results(varargin)
% TABLE_RESULTS M-file for table_results.fig
%      TABLE_RESULTS, by itself, creates a new TABLE_RESULTS or raises the existing
%      singleton*.
%
%      H = TABLE_RESULTS returns the handle to a new TABLE_RESULTS or the handle to
%      the existing singleton*.
%
%      TABLE_RESULTS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TABLE_RESULTS.M with the given input arguments.
%
%      TABLE_RESULTS('Property','Value',...) creates a new TABLE_RESULTS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before table_results_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to table_results_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help table_results

% Last Modified by GUIDE v2.5 02-Nov-2009 15:30:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @table_results_OpeningFcn, ...
                   'gui_OutputFcn',  @table_results_OutputFcn, ...
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


% --- Executes just before table_results is made visible.
function table_results_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to table_results (see VARARGIN)

% Choose default command line output for table_results
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes table_results wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = table_results_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in load_data.
function load_data_Callback(hObject, eventdata, handles)
% hObject    handle to load_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[filename, pathname] = uigetfile('*.*', 'Load data');
[numeric,txt,raw] = xlsread([pathname,filename]);

%now populate the table with the above values

set(handles.uitable1,'data',raw(2:end,:));
set(handles.uitable1,'ColumnName',raw(1,:));
set(handles.popupmenu1,'String',raw(1,:))

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

contents = get(hObject,'String');
item = contents{get(hObject,'Value')};
colnames = get(handles.uitable1,'ColumnName');
for inx = 1:length(colnames)
    if strcmp(colnames{inx},item)
        break;
    end
end
data = get(handles.uitable1,'data');
sort_column = cell2mat(data(:,inx));
[vs,inxs] = sort(sort_column,'descend');
data = data(inxs,:);
set(handles.uitable1,'data',data);

% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected cell(s) is changed in uitable1.
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to uitable1 (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

indices = eventdata.Indices;
first_selected_row_inx = indices(1,1);
data = get(handles.uitable1,'data');
bin_center = cell2mat(data(first_selected_row_inx,1));
main_h = getappdata(gcf,'main_h');
if ~isempty(main_h)
    max_spectrum = getappdata(main_h,'max_spectrum');
    min_spectrum = getappdata(main_h,'min_spectrum');
    x = getappdata(main_h,'x');
    regions = get_regions(main_h);
    nm = size(regions);
    centers = [];
    for i = 1:nm(1)
        centers(end+1) = mean(regions(i,:));
    end
    [v,ix] = min(abs(centers-bin_center));    
    inxs = find(regions(ix,1) >= x & x >= regions(ix,2));
    mx = max(max_spectrum(inxs));
    mn = min([0,min(min_spectrum(inxs))]);
    set(get(main_h,'CurrentAxes'),'xlim',[regions(ix,2),regions(ix,1)]);
    set(get(main_h,'CurrentAxes'),'ylim',[mn,mx]);
end