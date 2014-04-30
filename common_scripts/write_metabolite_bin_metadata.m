% FUNCTION WRITE_METABOLITE_BIN_METADATA
function completion_code = write_metabolite_bin_metadata(regions, deconvolve, names)
% regions
% deconvolve
% names
[filename,pathname] = uiputfile({'*.csv','Row-dominant comma-delimited (*.csv)'}, 'Save regions');

if (isnumeric(filename) && filename == 0)
    completion_code = -1;
    return;
end

[file_id, message] = fopen([pathname filename],'w');
if (file_id <= 2)
    msgbox(message);
    completion_code = -2;
    return;
end

num_bins = size(regions,1);

for b = 1:num_bins
    if ~isempty(names{b}) && ~strcmp(deblank(names{b}),'')
        names{b} = deblank(names{b});
    end
end

for b = 1:num_bins
    if deconvolve(b)
        fprintf(file_id,'%.16f,%.16f,"deconvolve","%s"\n',...
            regions(b,1),regions(b,2),names{b});
    else
        fprintf(file_id,'%.16f,%.16f,"sum","%s"\n',...
            regions(b,1),regions(b,2),names{b});
    end
end

fclose(file_id);
completion_code = 0;
