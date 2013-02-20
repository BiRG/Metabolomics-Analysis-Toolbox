function test_suite = test_paired_by_fields_listbox%#ok<STOUT>
%matlab_xUnit tests excercising paired_by_fields_listbox
%
% Usage:
%   runtests paired_by_fields_listbox
initTestSuite;

function testWith1DDuplicates %#ok<DEFNU>
% Tests whether correct behavior occurs when one field is selected and it
% has duplicates

fig = figure;
handles.paired_by_fields_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    ['first_name'; 'last_name '],'Value',1,'Max',2,'Min',1, ...
    'Position',[1,10,100,100]);
handles.paired_by_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    'Garbage','Value',[],'Max',1,'Min',1, ...
    'Position',[115,10,100,100]);
c.first_name = {'Mike','Jim','Mike'};
c.last_name = {'Miller','Smith','Doe'};
handles.collection = c;
guidata(fig, handles);
paired_by_fields_listbox(fig, handles);
new_handles = guidata(fig);
assertEqual(new_handles.paired_by_inxs, {[2], [1,3]});
assertEqual(get(handles.paired_by_listbox, 'String'),{'Jim';'Mike'});
assertEqual(get(handles.paired_by_listbox, 'Value'), 1);
assertEqual(get(handles.paired_by_listbox, 'Max'), 2);
delete(fig);


function testWith1DNoDuplicates %#ok<DEFNU>
% Tests whether correct behavior occurs when one field is selected and it
% has no duplicates

fig = figure;
handles.paired_by_fields_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    ['first_name'; 'last_name '],'Value',2,'Max',2,'Min',1, ...
    'Position',[1,10,100,100]);
handles.paired_by_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    'Garbage','Value',[],'Max',1,'Min',1, ...
    'Position',[115,10,100,100]);
c.first_name = {'Mike','Jim','Mike'};
c.last_name = {'Miller','Smith','Doe'};
handles.collection = c;
guidata(fig, handles);
paired_by_fields_listbox(fig, handles);
new_handles = guidata(fig);
assertEqual(new_handles.paired_by_inxs, {3,1,2});
assertEqual(get(handles.paired_by_listbox, 'String'),{'Doe';'Miller';'Smith'});
assertEqual(get(handles.paired_by_listbox, 'Value'), 1);
assertEqual(get(handles.paired_by_listbox, 'Max'), 3);
delete(fig);

function testWith2DNoDuplicates %#ok<DEFNU>
% Tests whether correct behavior occurs when two fields are selected and
% there are no duplicates
fig = figure;
handles.paired_by_fields_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    ['first_name'; 'last_name '],'Value',[1,2],'Max',2,'Min',1, ...
    'Position',[1,10,100,100]);
handles.paired_by_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    'Garbage','Value',[],'Max',1,'Min',1, ...
    'Position',[115,10,100,100]);
c.first_name = {'Mike','Jim','Mike'};
c.last_name = {'Miller','Smith','Doe'};
handles.collection = c;
guidata(fig, handles);
paired_by_fields_listbox(fig, handles);
new_handles = guidata(fig);
assertEqual(new_handles.paired_by_inxs, {2,3,1});
assertEqual(get(handles.paired_by_listbox, 'String'),{'Jim, Smith';'Mike, Doe';'Mike, Miller'});
assertEqual(get(handles.paired_by_listbox, 'Value'), 1);
assertEqual(get(handles.paired_by_listbox, 'Max'), 3);
delete(fig);

function testWith2DDuplicates %#ok<DEFNU>
% Tests whether correct behavior occurs when two fields are selected and
% there are duplicates
fig = figure;
handles.paired_by_fields_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    ['first_name'; 'last_name '],'Value',[1,2],'Max',2,'Min',1, ...
    'Position',[1,10,100,100]);
handles.paired_by_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    'Garbage','Value',[],'Max',1,'Min',1, ...
    'Position',[115,10,100,100]);
c.first_name = {'Mike', 'Mike', 'Jim'};
c.last_name = {'Miller','Miller','Smith'};
handles.collection = c;
guidata(fig, handles);
paired_by_fields_listbox(fig, handles);
new_handles = guidata(fig);
assertEqual(new_handles.paired_by_inxs, {3,[1,2]});
assertEqual(get(handles.paired_by_listbox, 'String'),{'Jim, Smith';'Mike, Miller'});
assertEqual(get(handles.paired_by_listbox, 'Value'), 1);
assertEqual(get(handles.paired_by_listbox, 'Max'), 2);
delete(fig);

function testWith2DEmpty %#ok<DEFNU>
% Tests whether correct behavior occurs when an empty string is one of the
% selected fields
fig = figure;
handles.paired_by_fields_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    ['first_name'; 'last_name ';'          '],'Value',[1,3],'Max',2,'Min',1, ...
    'Position',[1,10,100,100]);
handles.paired_by_listbox = uicontrol(fig, 'Style', 'listbox', 'String', ...
    'Garbage','Value',[],'Max',1,'Min',1, ...
    'Position',[115,10,100,100]);
c.first_name = {'Mike', 'Mike', 'Jim'};
c.last_name = {'Miller','Miller','Smith'};
handles.collection = c;
guidata(fig, handles);
paired_by_fields_listbox(fig, handles);
new_handles = guidata(fig);
assertEqual(new_handles.paired_by_inxs, {});
assertEqual(get(handles.paired_by_listbox, 'String'),'');
assertEqual(get(handles.paired_by_listbox, 'Value'), 1);
assertEqual(get(handles.paired_by_listbox, 'Max'), 1);
assertEqual(get(handles.paired_by_listbox, 'Min'), 0);
delete(fig);

