
%Available variables to use.
path = 'NMR_Peaklist/';
dirListing = dir(path); % Directory listing of the current directory.
molecules = struct('file', '', 'peakNumbers', 0, 'ppm', 0, 'hz', 0,...
    'peakHeight', 0, 'moleculeName', '');
fileCount = length(dirListing) - 2; % How many files are in the directory.
counter = 1;

try
    for i = 1:length(dirListing)
        lineCounter = 0;
        if(dirListing(i).isdir == 1)
            %This is a directory, no need to interact.
            %disp('This is a directory')
        else %Read in file data.
            fid = fopen([path,dirListing(i).name], 'r');
            tline = fgets(fid);
            arrayInc = 1;
            tableTwo = false; %Using this as a "don't use" case for reading table two.
            table_of_peaks = 0;

            while(tline ~= -1)
                if(lineCounter == 0) %Commented line of file
                    if isempty(regexp(tline,'HNMR'))
                        break;
                    end
                    molecules(counter).file = dirListing(i).name;  
                    molName = substring(tline, 13, length(tline) - 19);
                    molecules(counter).moleculeName = molName;
                elseif ~isempty(regexp(tline,'Table of Peaks')) && table_of_peaks == 0
                    table_of_peaks = 1;
                    tline = fgets(fid);
                    if ~isempty(regexp(tline,'No..*(ppm)'))
                        tline = fgets(fid); % Read next line
                    elseif isempty(regexp(tline, '[1-9]')) % Not a data point
                        tline = fgets(fid);
                        if ~isempty(regexp(tline,'No..*(ppm)'))
                            tline = fgets(fid); % Read next line
                        else
                            error_reading_file;
                        end
                    end
                end
                
                if table_of_peaks == 1
                    if(~isempty(regexp(tline, '[1-9]'))) %Skipping column headers  
                        peakData = textscan(tline, '%d%s%s%s');

                        molecules(counter).peakNumbers(arrayInc) = peakData{1};
                        molecules(counter).ppm(arrayInc) = str2num(peakData{2}{1});
                        try
                            molecules(counter).hz(arrayInc) = str2num(peakData{3}{1});
                        catch ME
                            molecules(counter).hz(arrayInc) = NaN;
                        end
                        try
                            molecules(counter).peakHeight(arrayInc) = str2num(peakData{4}{1});
                        catch ME
                            molecules(counter).peakHeight(arrayInc) = molecules(counter).hz(arrayInc);
                            molecules(counter).hz(arrayInc) = NaN;
                        end
                        arrayInc = arrayInc +1;
                    else
                        table_of_peaks = 2;
                    end
                end% End of Reading
                lineCounter = lineCounter + 1;
                tline = fgets(fid);
            end % End of file.
            counter = counter + 1;
            fclose(fid);       
        end
    end
    save('molecules','molecules');
    disp('Finished!')
catch ME
    disp('Exception');
    %Something was wrong with a file, unknown character etc.
end