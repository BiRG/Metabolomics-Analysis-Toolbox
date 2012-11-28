function write_nssd_entry(nssd_root, dirname, exp_no, proc_no, heights, widths, lors, ppms, freq_range, num_samples)
% Write an artificial spectrum directory to the given NSSD
%
% Usage: write_nssd_entry(nssd_root, dirname, exp_no, proc_no, heights, widths, lors, ppms, freq_range, num_samples)
%
% Where:
%
% nssd_root   a string. The path to the root directory in which 
%             all nssd entries' directories live
%
% dirname     a string. The name of the directory into which the data for 
%             the current entry will be placed
%
% exp_no      a string. The number of the experiment whose data is used
%
% proc_no     a string. The number of the processing run whose data is used
%
% heights     an array of double. heights(i) is the height of the i'th peak
%
% widths      an array of double. widths(i) is the width at half-height of
%             the i'th peak
%
% lors        an array of double. lor(i) is the lorentzianness parameter of
%             the i'th gauss-lorentz peak
%
% ppms        an array of double. ppms(i) is the ppm location of the mode
%             of the i'th gauss-lorentz peak.
%
% freq_range  an array of double with two entries. freq_range(1) is the
%             minimum ppm value in the generated spectrum. freq_range(2) is
%             the maximum ppm value in the generated spectrum.
%
% num_samples a scalar containing the number of samples to place in the
%             generated spectrum
%


% Set up the peak parameters in the form needed by the GaussLorentzPeak
% constructor
if iscolumn(heights); heights = heights'; end
if iscolumn(widths);  widths = widths'; end
if iscolumn(lors);  lors = lors'; end
if iscolumn(ppms);  ppms = ppms'; end

peak_params = [heights; widths; lors; ppms];
peak_params = reshape(peak_params, 1, []);

% Create peak objects
peaks = GaussLorentzPeak(peak_params);

% Determine the x values (makes a row vector) - note that they must be
% decreasing so that the y values are in the right order in their file
max_f = max(freq_range);
min_f = min(freq_range);
x = linspace(max_f, min_f, num_samples);

% Determine the y values (makes a row vector)
y = sum(peaks.at(x),1);

% Scale the y values to a 64 bit signed integer.
max_int64 = int64(9223372036854775807);
max_y = max(abs(y));
y_int = int64(zeros(size(y)));
for i = 1:length(y_int)
    y_int(i) = int64(max_int64*(y(i)/max_y));
end

% Determine the sw, sf, si, byteordp, and offset parameters
offset = max_f;
sw = max_f - min_f;
sf = 1;
si = -1; %Garbage since not used in reading 1d spectra
byteordp = 0; % Write everything little endian because we're on a PC
byteord_str = 'l';

% Ensure that the correct directory exists to contain the new data
proc_dir = fullfile(nssd_root, dirname, exp_no, 'pdata', proc_no);
[success,message_id,message]=mkdir(proc_dir);
if ~success
    error(message_id,'Could not create directory %s. Message: %s', ...
        proc_dir, message);
end

% Compute the file names
rfile = fullfile(nssd_root, dirname, exp_no, 'pdata', proc_no,'1r'); % Real axis samples
ifile = fullfile(nssd_root, dirname, exp_no, 'pdata', proc_no,'1i'); % Imaginary axis samples
pfile = fullfile(nssd_root, dirname, exp_no, 'pdata', proc_no,'procs'); % Processing parameters

% Write the processing parameters
fid = fopen(pfile,'wt');
fprintf(fid,'##$OFFSET= %.18g', offset);
fprintf(fid,'##$SW_p= %.18g', sw);
fprintf(fid,'##$SF= %.18g', sf);
fprintf(fid,'##$SI= %.18g', si);
fprintf(fid,'##$BYTORDP= %d', byteordp);
fclose(fid);

% Write the real data
fid = fopen(rfile,'w',byteord_str);
fwrite(fid,y_int,'integer*4');
fclose(fid);

% Write the imaginary data (all zeros)
fid = fopen(ifile,'w',byteord_str);
fwrite(fid,int64(zeros(size(y_int))),'integer*4');
fclose(fid);

end

