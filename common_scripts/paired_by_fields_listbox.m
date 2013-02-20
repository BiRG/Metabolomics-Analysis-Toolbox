function paired_by_fields_listbox(hObject,handles)
% Update the ui to reflect the current values of the paired_by_fields_listbox
%
% Populates the handles.paired_by_listbox object with the values contained 
% in the tuples of fields selected in paired_by_fields_listbox.
%
% Consider if handles.paired_by_fields_listbox contains 'first_name' and
% 'last_name' and collection.first_name = {'Mike','Jim','Mike'} and
% collection.last_name = {'Miller','Smith','Doe'}. Then, if only
% 'first_name' is selected, at the end handles.paired_by_listbox will
% contain 'Jim' and 'Mike'. But if both 'first_name' and 'last_name' are
% selected, then it will contain 'Jim Smith','Mike Doe', and 'Mike Miller'.
%
% Additionally, sets handles.paired_by_inxs to a cell array. For shorthand,
% call this array c. c{i} contains the indices of those samples in
% handles.collection that have the i'th value in
% collection.paired_by_listbox.
%
% If one of the selected entries in the handles.paired_by_fields_listbox 
% object is the empty string, the paired_by_listbox object is set to empty
% and the paired_by_inxs is set to the empty cell array.
%
% If no fields are selected in the handles.paired_by_fields_listbox, a
% warning dialog is displayed and nothing else is changed.
%
% Note: all comments in this file were added after-the-fact by Eric Moyer
% based on his reading of the code and therefore may be a misinterpretation
% of the intention of the original author.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% hObject - the handle to an object in the figure that will be updated
%
% handles - a GUIDE handles struct which contains a
%    'paired_by_fields_listbox', a 'paired_by_listbox', and a 'collection'
%    field. collection contains the current collection struct,
%    paired_by_fields_listbox contains the handle of a listbox whose
%    entries are the names of fields in the collection struct,
%    paired_by_listbox will be populated by the values contained in the
%    tuples of fields selected in paired_by_fields_listbox.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% none (but updates the GUI by setting the guidata on hObject to the
%    updated handles struct)
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% none ( but see test cases in common_scripts/tests )
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Paul Anderson (before July 2011)
%
% Eric Moyer (February 2013) eric_moyer@yahoo.com
%
contents = cellstr(get(handles.paired_by_fields_listbox,'String'));
selected_fields = contents(get(handles.paired_by_fields_listbox,'Value'));
if isempty(selected_fields)
    msgbox('Select at least one paired by field');
    return;
end

for i = 1:length(selected_fields)
    if isempty(selected_fields{i}) % Empty space was selected, so reset
        set(handles.paired_by_listbox,'String',[]);
        set(handles.paired_by_listbox,'Max',1);
        set(handles.paired_by_listbox,'Min',0);
        set(handles.paired_by_listbox,'Value',1);
        
        handles.paired_by_inxs = {};
        guidata(hObject, handles);
        
        return;
    end
end
        

[sorted_fields_str,paired_by_inxs,inxs] = by_fields_listbox(handles.collection,selected_fields);

set(handles.paired_by_listbox,'String',sorted_fields_str);
set(handles.paired_by_listbox,'Max',length(sorted_fields_str));
set(handles.paired_by_listbox,'Value',1);

handles.paired_by_inxs = {paired_by_inxs{inxs}};

% Update handles structure
guidata(hObject, handles);
