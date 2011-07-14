function varargout = AddCustMolecule(varargin)
% ADDCUSTMOLECULE M-file for AddCustMolecule.fig
%      ADDCUSTMOLECULE, by itself, creates a new ADDCUSTMOLECULE or raises the existing
%      singleton*.
%
%      H = ADDCUSTMOLECULE returns the handle to a new ADDCUSTMOLECULE or the handle to
%      the existing singleton*.
%
%      ADDCUSTMOLECULE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADDCUSTMOLECULE.M with the given input arguments.
%
%      ADDCUSTMOLECULE('Property','Value',...) creates a new ADDCUSTMOLECULE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AddCustMolecule_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AddCustMolecule_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AddCustMolecule

% Last Modified by GUIDE v2.5 11-Jan-2010 17:20:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AddCustMolecule_OpeningFcn, ...
                   'gui_OutputFcn',  @AddCustMolecule_OutputFcn, ...
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


% --- Executes just before AddCustMolecule is made visible.
function AddCustMolecule_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AddCustMolecule (see VARARGIN)

% Choose default command line output for AddCustMolecule
handles.output = hObject;
set(handles.figure1,'CloseRequestFcn',@closeGUI);

% Sets up the boxes format.
set(handles.errorBox, 'Visible', 'Off');
set(handles.errorBox, 'BackGroundColor', 'Red');
set(handles.saveBox, 'Visible', 'Off');

% Sets up buttons for visibilities. (And Table)
set(handles.saveButton, 'Visible', 'Off');
set(handles.resetButton, 'Visible', 'Off');
set(handles.closeAfterButton, 'Visible', 'Off');
set(handles.previewButton, 'Visible', 'Off');
set(handles.infoTable, 'Visible', 'Off');
set(handles.closeBeforeButton, 'Visible', 'On');
set(handles.doneButton, 'Visible', 'On');

% Variables that may be used.
handles.tableLength = 0;
handles.numPeaksTemp = 0;
handles.molNameTemp = '';

handles.custMolecules = struct('file', 'Custom', 'peakNumbers', 0, 'ppm', 0, 'hz', 0,...
    'peakHeight', 0, 'moleculeName', '');

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes AddCustMolecule wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AddCustMolecule_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function molName_Callback(hObject, eventdata, handles)
% hObject    handle to molName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of molName as text
%        str2double(get(hObject,'String')) returns contents of molName as a
%        double

% --- Executes during object creation, after setting all properties.
function molName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to molName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
elseif ismac && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Update handles structure
guidata(hObject, handles);

function numPeaks_Callback(hObject, eventdata, handles)
% hObject    handle to numPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of numPeaks as text
%        str2double(get(hObject,'String')) returns contents of numPeaks as a double


% --- Executes during object creation, after setting all properties.
function numPeaks_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numPeaks (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
elseif ismac && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in previewButton.
function previewButton_Callback(hObject, eventdata, handles)
% hObject    handle to previewButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Makes sure everything is in the molecule (doesn't mean saved)
data = get(handles.infoTable, 'Data');
handles.custMolecules.moleculeName = get(handles.molName,'String');
handles.custMolecules.peakNumbers = get(handles.numPeaks,'String');
for m = 1:handles.tableLength
    try
        handles.custMolecules.peakHeight(m) = cell2mat(data(m,1));
    catch ME
        handles.custMolecules.peakHeight(m) = 0;
    end
    
    try
        handles.custMolecules.ppm(m) = cell2mat(data(m,2));
    catch ME
        handles.custMolecules.ppm(m) = 0;
    end
        
    try
        handles.custMolecules.hz(m) = cell2mat(data(m,3));
    catch ME
        handles.custMolecules.hz(m) = 0;
    end
end

% Calls Paul's function to show the molecule in a graphical way.
show_molecule(handles.custMolecules(1));

% Update handles structure
guidata(hObject, handles);

% Passes molecule to view_molecule function


% --- Executes on button press in doneButton.
function doneButton_Callback(hObject, eventdata, handles)
% hObject    handle to doneButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Checks if the number enetered in NumPeaks is a number.
if(~isnan(str2double(get(handles.numPeaks, 'String'))))
    handles.molNameTemp = get(handles.molName,'String');
    handles.numPeaksTemp = str2double(get(handles.numPeaks, 'String'));
    
    % More Error Checking!
    if((handles.numPeaksTemp - floor(handles.numPeaksTemp) == 0))
        % Number has no decimals
        if((handles.numPeaksTemp > 0) && (handles.numPeaksTemp < realmax('single')))
            % And numPeaksTemp is positive, this is good number, moving
            % forward with calculations.

            % Makes the button invisible after being used.
            set(handles.doneButton, 'Visible', 'Off');

            % No need for error box, makes invisible
            set(handles.errorBox, 'Visible', 'Off');

            % Figures out the length of the table, updates the handle and fixes the
            % table's actual length.
            fixTable2Size = cell(str2double(get(handles.numPeaks,'String')),3);
            handles.tableLength = str2double(get(handles.numPeaks,'String'));
            set(handles.infoTable,'data',fixTable2Size);

            % Makes the table visible after done is clicked.
            set(handles.infoTable, 'Visible', 'On');

            % Makes the buttons invisible after not being needed.
            set(handles.closeBeforeButton, 'Visible', 'Off');
            set(handles.doneButton, 'Visible', 'Off');
            
            % Makes the new buttons visible that might need used.
            set(handles.resetButton, 'Visible', 'On');
            set(handles.saveButton, 'Visible', 'On');
            set(handles.closeAfterButton, 'Visible', 'On');
            set(handles.previewButton, 'Visible', 'On');
            
        else
            % Invalid because < 1, ERROR
            set(handles.errorBox,'String','Error: Number of Peaks < 1 or > Max'); 
            set(handles.errorBox, 'Visible', 'On');
        end
    else
        % Invalid because numPeaks has a decimal, ERROR
        set(handles.errorBox,'String','Error: Number of Peaks Cannot Be Decimal');
        set(handles.errorBox, 'Visible', 'On');
    end
else
    % Invalid number ERROR
    set(handles.errorBox,'String','Error: Number of Peaks Invalid'); 
    set(handles.errorBox, 'Visible', 'On');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in resetButton.
function resetButton_Callback(hObject, eventdata, handles)
% hObject    handle to resetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Reset top box values and table length
handles.tableLength = 0;
set(handles.molName,'String',''); 
set(handles.numPeaks,'String',''); 

% Sets up the boxes format.
set(handles.errorBox, 'Visible', 'Off');
set(handles.errorBox, 'BackGroundColor', 'Red');
set(handles.saveBox, 'Visible', 'Off');

% Sets up buttons for visibilities. (And Table)
set(handles.saveButton, 'Visible', 'Off');
set(handles.resetButton, 'Visible', 'Off');
set(handles.closeAfterButton, 'Visible', 'Off');
set(handles.previewButton, 'Visible', 'Off');
set(handles.saveBox, 'Visible', 'Off');
set(handles.infoTable, 'Visible', 'Off');
set(handles.closeBeforeButton, 'Visible', 'On');
set(handles.doneButton, 'Visible', 'On');


% --- Executes when entered data in editable cell(s) in infoTable.
function infoTable_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to infoTable (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)

%Grabs the value of the row and column that was edited for use.
col = eventdata.Indices(1,2);
row = eventdata.Indices(1,1);

% Creates a data variable, edits the value in the table, and passes it
% back to get updated.
data = get(handles.infoTable,'Data');
data(row, col) = num2cell(str2double(eventdata.EditData));
disp(data);

set(handles.infoTable,'Data',data);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in saveButton.
function saveButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Loads the database file generated by "readinfiles.m" after checking for a
% already-modified library file.  The modified has priority.
if((exist('molecules_library_edited.mat', 'file') > 0))
    load molecules_library_edited.mat
    handles.molecules = molecules;
elseif ((exist('molecules_library.mat', 'file') > 0))
    load molecules_library.mat
    handles.molecules = molecules;
else
    set(handles.saveBox, 'BackGroundColor', 'Red');
    set(handles.saveBox, 'String', 'Error loading existing library, check directory!');
    set(handles.saveBox, 'Visible', 'On');
end

% Puts all the data from the tables/boxes into the custMolecules structure
data = get(handles.infoTable, 'Data');
handles.custMolecules.moleculeName = get(handles.molName,'String');
handles.custMolecules.peakNumbers = get(handles.numPeaks,'String');
for m = 1:handles.tableLength
    try
        handles.custMolecules.peakHeight(m) = cell2mat(data(m,1));
    catch ME
        handles.custMolecules.peakHeight(m) = 0;
    end
    
    try
        handles.custMolecules.ppm(m) = cell2mat(data(m,2));
    catch ME
        handles.custMolecules.ppm(m) = 0;
    end
        
    try
        handles.custMolecules.hz(m) = cell2mat(data(m,3));
    catch ME
        handles.custMolecules.hz(m) = 0;
    end
end

% Updates the library file to have this at the end of it.
handles.molecules((length(handles.molecules) + 1)) = handles.custMolecules;

% Saves the library file with a new ending _Edited, to preserve original
% working library file in tact.
molecules = handles.molecules;
try
    % Attempts to save the file with no errors.
    save('molecules_library_edited.mat','molecules');
    set(handles.saveBox, 'BackGroundColor', 'Green');
    set(handles.saveBox, 'String', 'Molecule Saved!');
    set(handles.saveBox, 'Visible', 'On');
catch ME
    % Something went wrong with saving the file.
    set(handles.saveBox, 'BackGroundColor', 'Red');
    set(handles.saveBox, 'String', 'Error saving molcule!');
    set(handles.saveBox, 'Visible', 'On');
end

% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function infoTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to infoTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function errorBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to errorBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in closeAfterButton.
function closeAfterButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeAfterButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg('Any unsaved data will be lost, are you sure you want to quit?',...
                     'Confirmation Window',...
                     'Yes','No','Yes');
switch selection,
   case 'Yes',
    delete(gcf)
   case 'No'
     return
end


% --- Executes on button press in closeBeforeButton.
function closeBeforeButton_Callback(hObject, eventdata, handles)
% hObject    handle to closeBeforeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

selection = questdlg('Any unsaved data will be lost, are you sure you want to quit?',...
                     'Confirmation Window',...
                     'Yes','No','Yes');
switch selection,
   case 'Yes',
    delete(gcf)
   case 'No'
     return
end


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
    
