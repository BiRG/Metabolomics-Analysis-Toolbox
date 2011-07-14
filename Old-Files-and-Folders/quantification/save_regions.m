function save_regions
[regions,left_handles,right_handles] = get_regions;
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
        info = getappdata(left_handles(b),'info');
        if isempty(info)
            info.binning_method = 'sum';
        end
        if b > 1
            fprintf(file,';');
        end
        fprintf(file,'%s',info.binning_method);
    end    
    fclose(file);
end