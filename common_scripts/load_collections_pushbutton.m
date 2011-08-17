function handles = load_collections_pushbutton(handles)
collections = load_collections;
if isempty(handles.collections)
    return
end

handles.collection = merge_collections_cell(collections);

clear_all(handles.figure1,handles);

set(handles.description_text,'String',handles.collection.description);
