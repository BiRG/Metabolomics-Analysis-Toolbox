function interactive_quantify_known( )
%QUANTIFY_KNOWN Interactive quantification of peaks known from bin-map
%   The user selects a bin map and spectrum collection and identifies the 
%   peaks mentioned in the bin map.  Then the program deconvolves the bins
%   and removes the selected peaks, saving a quantification of the
%   particular compounds in one file and the residual spectrum in another
%   file.

uiwait(msgbox('Please choose a bin map file in the next screen',...
    'Please choose a bin map file','modal'));
bin_map = interactive_load_binmap;

if isempty(bin_map)
    msgbox('No bin map was selected. Goodbye.','Error','error','modal');
    return;
end

uiwait(msgbox('Please choose a spectrum collection file in the next screen. Only the first will be used.',...
    'Please choose a spectrum collection','modal'));

collections = load_collections;
if isempty(collections)
    msgbox('No collection was selected. Goodbye.','Error','error','modal');
    return;
end

collection = collections{1};

%Use appdata in matlab root to pass the loaded collections and bins to the
%gui the gui will remove this data when it reads it
setappdata(0, 'collection', collection);
setappdata(0, 'bin_map', bin_map);

targeted_identify;

end

