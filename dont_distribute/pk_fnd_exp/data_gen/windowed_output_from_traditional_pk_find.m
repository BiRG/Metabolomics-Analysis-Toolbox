function windowed_output_from_traditional_pk_find( spectrum_indices, output_filename )
%Write output of traditional peak finding to arff file for processing by waffles tools
%
%Usage: windowed_output_from_traditional_pk_find( spectrum_indices, output_filename )
%
%******************************************
% Detailed description
%******************************************
%
% Reads the spectra from synthetic_spectrum_filename.  Extracts the spectra
% at the given indices.  Then finds the peaks in those spectra.  Finally,
% Writes an arff file to output_filename.  It has 3 attributes.
%
% "spectrum identifier": the index of the spectrum that was analyzed
% "window center index": the sample index within the spectrum closest to the location where the peak was detected
% "has peaks": whether a peak was detected.
%
% It writes one pattern for each sample in each input spectrum.
%
%******************************************
% Example
%******************************************
%
%>> windowed_output_from_traditional_pk_find( [3,4], "sp_3_4_trad_find.arff")
%
% Would output peak locations from spectra 3 and 4 of the collection
% specified by synthetic_spectrum_filename

all_spectra = load(synthetic_spectrum_filename);
s = all_spectra.spectra(spectrum_indices);
num_s = length(s);

%Calculate peaks by finding smoothed maxima
std_dev = zeros(num_s,1); %estimated noise standard deviation of s{i}.y
std_dev_indices = (1:30);%y indices used for estimating noise standard dev - must be a range
peaks = cell(num_s,1);   %maxes{i} indices of the peaks in s{i}.y
for i = 1:num_s
    std_dev(i) = std(s{i}.y(std_dev_indices));
    peaks{i} = wavelet_find_maxes_and_mins(s{i}.y,std_dev(i));
end


% Write the file
fid = fopen(output_filename,'w');
if fid < 0
    error(['Cannot open file ' out_filename]);
end

fprintf(fid,'%% Output of smoothed max finding for synthetic spectra\n');
fprintf(fid,'%% \n');
fprintf(fid,'%% A noise estimate was made using a certain range of \n');
fprintf(fid,'%% indices from the original spectrum\n');
fprintf(fid,'%% \n');
fprintf(fid,'%% All local maxima in the smoothed spectrum with height\n');
fprintf(fid,'%% greater than the 5 standard deviations above mean were peaks\n');
fprintf(fid,'%% \n');
fprintf(fid,'%% Parameters: \n');
fprintf(fid,'%%    Input file:                     %s\n', synthetic_spectrum_filename);
fprintf(fid,'%%    Output file:                    %s\n', output_filename);
fprintf(fid,'%%    Noise indices:                  [%d, %d]\n', ...
    min(std_dev_indices), max(std_dev_indices));
fprintf(fid,'%% \n');
fprintf(fid,'%% \n');

fprintf(fid,'@relation "smoothed maxes for spectra %d', spectrum_indices(1));
fprintf(fid,',%d', spectrum_indices(2:end));
fprintf(fid,'"\n');

fprintf(fid,'\n');
fprintf(fid,'@attribute "spectrum identifier" integer\n');
fprintf(fid,'@attribute "window center index" integer\n');
fprintf(fid,'@attribute "has peaks" {false,true}\n');
fprintf(fid,'\n');


fprintf(fid,'@data\n');
for s_idx=1:num_s
    num_y = length(s{s_idx}.y);
    
    %has_peak is a logical array that is true if s{s_idx}.y(i) is a peak
    has_peak = false(num_y,1); %set it all to false
    has_peak(peaks{s_idx}) = true(length(peaks{s_idx}),1); %set peak locations to true
    
    %print the values for all y
    for i=1:num_y
        fprintf(fid,'%d',spectrum_indices(s_idx));
        fprintf(fid,',%d',i);
        if has_peak(i)
            fprintf(fid,',true\n');
        else
            fprintf(fid,',false\n');
        end
    end 
end        