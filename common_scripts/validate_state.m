function [is_valid_state,message] = validate_state( handles, version_string)
%VALIDATE_STATE Validates a program to make sure a collection is loaded and
%the version matches the executable.
is_valid_state = true;
message = '';

if ~strcmp(get(handles.version_text,'String'),version_string)
    is_valid_state = false;
    message = sprintf('Versions do not match. Find and run version %s',get(handles.version_text,'String'));
    return;
end

if ~isfield(handles,'collection')
    is_valid_state = false;
    message = 'No collection loaded';
    return;
end

