
%Available variables to use.
path = 'NMR_Test/';
dirListing = dir(path); % Directory listing of the current directory.
molecules = struct('file', '', 'peakNumbers', 0, 'ppm', 0, 'hz', 0,...
    'peakHeight', 0, 'moleculeName', '', 'type', '');
fileCount = length(dirListing) - 2; % How many files are in the directory.
counter = 1;

try
    for i = 1:length(dirListing)
        lineCounter = 0;
        if((dirListing(i).isdir == 1) || strcmp(dirListing(i).name, '.DS_Store'))
            %This is a directory, no need to interact or library file.
            %disp('This is a directory')
        else %Read in file data.
            
            % Setting up variables - unique to each file.  
            fid = fopen([path,dirListing(i).name], 'r');
            tline = fgets(fid);
            arrayInc = 1;
            tableTwo = false; %Using this as a "don't use" case for reading table two.
            table_of_peaks = 0;
            table_of_multiplets = 0;

            while(tline ~= -1)
                % Checks commented line for HNMR tag, if none - skips.
                if(lineCounter == 0) 
                    if isempty(regexp(tline,'HNMR'))
                        break;
                    else
                        % This is not HNMR file, skip it.
                    end
                    
                    % Assigns known values assuming it is correct file
                    % type after comment line check.
                    molecules(counter).file = dirListing(i).name;  
                    molName = substring(tline, 13, length(tline) - 19);
                    molecules(counter).moleculeName = molName;
                    
                % Checks for phrase Table of Peaks in line and marks the
                % phrase as used (it only appears once in the files).
                elseif ~isempty(regexp(tline,'Table of Peaks')) && table_of_peaks == 0
                    table_of_peaks = 1; 
                    tline = fgets(fid); % Tagged as used, move to next line.
                    
                    % Checks for titles of columns then skips line if found.
                    if ~isempty(regexp(tline,'No..*(ppm)'))
                        tline = fgets(fid);
                        
                    % Checks to make sure numbers are in the line, gets
                    % next line if this is not the case.
                    elseif isempty(regexp(tline, '[1-9]'))
                        tline = fgets(fid);
                        
                        % Checks for column headers, skips if found,
                        % something is not right if not - shows error.
                        if ~isempty(regexp(tline,'No..*(ppm)'))
                            tline = fgets(fid); % Read next line
                        else
                            error_reading_file;
                        end
                    end
                elseif ~isempty(regexp(tline, 'Table of Multiplets')) && table_of_multiplets == 0
                    table_of_multiplets = 1;
                    tline = fgets(fid); % Tagged as used, move to next line.
                    
                    % Checks for titles of columns then skips line if found.
                    if ~isempty(regexp(tline, 'No..*Shift1'))
                        tline = fgets(fid);
                        
                    % Checks to make sure numbers are in the line, gets
                    % next line if this is not the case.
                    elseif isempty(regexp(tline, '[1-9]'))
                        tline = fgets(fid);
                        
                        % Checks for column headers, skips if found,
                        % something is not right if not - shows error.
                        if ~isempty(regexp(tline,'No..*(ppm)'))
                            tline = fgets(fid); % Read next line
                        else
                            disp('Table of Multiples Section Error');
                            error_reading_file;
                        end
                    end
                else
                end
                
                % This conditional means you are under the table with the
                % name "Table of Peaks" and will pluck out the data needed
                % and assign it to the molecule structure associated with
                % it.
                if table_of_peaks == 1
                    
                    % Another check for column headers then reads in the
                    % data for the table. Jumps out of table if no data.
                    if(~isempty(regexp(tline, '[1-9]')))    
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
                        % Jumping out of the table in the logic.
                        table_of_peaks = 2;
                    end
                end % End of Reading Table of Peaks.
                
                % This conditional means you are under the table with the
                % name "Table of Multiplets" and will pluck out the data
                % needed and assign it to the molecule structure associated
                % with it.
                if table_of_multiplets == 1;
                    % Another check for column headers then reads in the
                    % data for the table. Jumps out of table if no data.
                    if(~isempty(regexp(tline, '[1-9]')))    
                        % No., Shift1, (ppm), H's, Type, J (Hz), Atom1,
                        % Multiplet1 (ppm)
                        peakData = textscan(tline, '%d%f%d%s%s%d%s%s%s%s');
                        % Note: This works unless J ~= '-'
                        
                        arrayInc = arrayInc +1;
                    else
                        % Jumping out of the table in the logic.
                        table_of_multiplets = 2;
                    end
                end
                
                % Progressing to next line
                lineCounter = lineCounter + 1;
                tline = fgets(fid);
            end % End of file.
            counter = counter + 1;
            fclose(fid);       
        end
    end
    save('molecules_library_dev','molecules');
    disp('Finished!')
catch ME
    disp('Exception');
    %Something was wrong with a file, unknown character etc.
end


%
%z = y(10);
%z = cell2struct(z, 'hello', 1);
%z = z.hello(1);
%z = cellstr(z);
%