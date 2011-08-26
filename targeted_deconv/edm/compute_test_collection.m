function [ collection, bin_map, deconvolved, deconv_peak_obj, peak_obj ] = compute_test_collection( num_spectra, noise_amplitude )
%Computes a test spectral collection and its correct deconvolution
%   Computes a spectral collection for testing region deconvolution with a
%   given amplitude of Gaussian white noise.  The correct bin_map and
%   deconvolution are included in the output.
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
%
% num_spectra      The number of spectra generated
%
% noise_amplitude  The amplitude of the Gaussian white noise added to the
%                  signal after generation
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
%
% collection      The spectral collection object generated
%
% bin_map         An array of CompoundBin objects for use in deconvolving
%                 the spectrum
%
% deconvolved     A spectral collection containing the deconvolved peaks
%
% deconv_peak_obj All GaussLorentzPeak objects used in the deconvolution.
%                 This is a cell array containing arrays of
%                 GaussLorentzPeak objects
%                 deconv_peak_obj{bin_idx, spectrum_idx} will be an array
%                 of all the peaks in that bin sorted in order of x values
%
% peak_obj        All GaussLorentzPeak objects used to generate the
%                 spectrum.  This is a matrix accessed as: 
%                 peak_obj(peak_number, spectrum_idx)
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% [collection, bin_map, deconvolved, deconv_peak_obj, peak_obj] = ...
%         compute_test_collection(1,0.3)
%
% Will generate a collection with 1 spectrum with and noise of 0.3 units

% First compound - a lorentzian singlet smack-dab in the middle of 
% the first 100 x values
cur_bin=1;
cur_id = cur_bin+999999;
bin_map=CompoundBin({cur_id,'20 wide 20+/-1 high singlet',100,1,'s','clean','U01', ...
    'TestSpectrum'});

noise = noise_amplitude;
peak_num = 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(20+2*rand(1)-1)*noise, ...
        10,1,50] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end

% Second compound - a smaller lorentzian singlet smack-dab in the middle of 
% the second 100 x values
cur_bin=cur_bin + 1;
cur_id = cur_bin+999999;
bin_map(cur_bin) = ...
    CompoundBin({cur_id,'20 wide 6+/-1 high singlet',200,101,'s','clean','U02', ...
    'TestSpectrum'});

peak_num = peak_num + 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(6+2*rand(1)-1)*noise, ...
        10,1,150] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end

% Third compound - a now make the previous singlet half-gaussian 
cur_bin=cur_bin + 1;
cur_id = cur_bin+999999;
bin_map(cur_bin) = ...
    CompoundBin({cur_id,'20 wide 6+/-1 high singlet - half gaussian',... 
        300,201,'s','clean','U03', ...
        'TestSpectrum'});

peak_num = peak_num + 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(6+2*rand(1)-1)*noise, ...
        10,0.5,250] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end

% Fourth compound - a very narrow (but tall) lorentzian singlet smack-dab in the middle of 
% the fourth 100 x values
cur_bin=cur_bin + 1;
cur_id = cur_bin+999999;
bin_map(cur_bin) = ...
    CompoundBin({cur_id,'2 wide 20+/-1 high singlet',400,301,'s','clean','U04', ...
    'TestSpectrum'});

peak_num = peak_num + 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(20+2*rand(1)-1)*noise, ...
        1,1,350] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end


% Fifth compound - a very narrow and short lorentzian singlet smack-dab in the middle of 
% the fifth 100 x values 
cur_bin=cur_bin + 1;
cur_id = cur_bin+999999;
bin_map(cur_bin) = ...
    CompoundBin({cur_id,'2 wide 6+/-1 high singlet',500,401,'s','clean','U05', ...
    'TestSpectrum'});

peak_num = peak_num + 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(6+2*rand(1)-1)*noise, ...
        1,1,450] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end


% Sixth compound - a peak in the middle of a very congested area
% composed of the values from 550-650, all peaks in the area are seen.  All
% congesting peaks are 10 wide and range from 10 to 20 (+/-1) high
cur_bin=cur_bin + 1;
cur_id = cur_bin+999999;
bin_map(cur_bin) = ...
    CompoundBin({cur_id,'10w 40+/-1h singlet congested all seen',650, 550,'s','clean','U06', ...
    'TestSpectrum'});

peak_num = peak_num + 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(40+2*rand(1)-1)*noise, ...
        5,1,600] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end


congestion_xs=[564	577	581	587	590	597	598	599	605	606	608	632];
congestion_hs=[10	12	13	13	12	13	10	13	14	18	20	14];
num_congestion=length(congestion_xs);
for congestion_idx = 1:num_congestion
    for i=1:num_spectra
        h=congestion_hs(congestion_idx);
        x=congestion_xs(congestion_idx);
        peak_obj(peak_num+congestion_idx,i)=...
            GaussLorentzPeak( [(h+2*rand(1)-1)*noise, ...
            5,1,x] ); %#ok<AGROW>
    end
end
peak_num=peak_num+num_congestion;

% Seventh compound - a peak in the middle of a less congested area
% composed of the values from 750-850, all peaks in the area are seen.  All
% congesting peaks are 10 wide and range from 10 to 20 (+/-1) high
cur_bin=cur_bin + 1;
cur_id = cur_bin+999999;
bin_map(cur_bin) = ...
    CompoundBin({cur_id,'10w 40+/-1h singlet less congested all seen',850, 750,'s','overlap','U07', ...
    'TestSpectrum'});

peak_num = peak_num + 1;
for i=1:num_spectra
    peak_obj(peak_num,i)=GaussLorentzPeak( [(40+2*rand(1)-1)*noise, ...
        5,1,800] ); %#ok<AGROW>
    deconv_peak_obj{cur_bin, i}=peak_obj(peak_num,i); %#ok<AGROW>
end


congestion_xs=[777	813	821	823	828];
congestion_hs=[16	15	20	19	10];
num_congestion=length(congestion_xs);
for congestion_idx = 1:num_congestion
    for i=1:num_spectra
        h=congestion_hs(congestion_idx);
        x=congestion_xs(congestion_idx);
        peak_obj(peak_num+congestion_idx,i)=...
            GaussLorentzPeak( [(h+2*rand(1)-1)*noise, ...
            5,1,x] ); %#ok<AGROW>
    end
end
peak_num=peak_num+num_congestion; %#ok<NASGU>  This will be copied


% Create the collection
collection.filename = 'not_yet_saved_to_a_file.txt';
collection.input_names= {'Collection ID'    'Type'    'Description' ...
    'Processing log'};
collection.x=1024:-1:1;
collection.Y=zeros(length(collection.x),num_spectra); %Will fill in values later
collection.num_samples = num_spectra;
collection.collection_id = '-101';
collection.type = 'SpectraCollection';
collection.description = ['Artificially generated spectrum ' ...
    'collection for testing targeted deconvolution'];
collection.processing_log = 'Generated.';

% Calculate the Y values
s=size(peak_obj);
num_peaks = s(1);
for spec=1:num_spectra
    sum=zeros(length(collection.x),1);
	for peak=1:num_peaks
        g=peak_obj(peak,spec);
        y=g.at(collection.x);
        sum = sum + y';
	end
    collection.Y(:, spec)=sum;
end

% Add noise
noise_val = normrnd(0, noise_amplitude, size(collection.Y));
collection.Y = collection.Y + noise_val;

% Create the deconvolved collection
num_peaks_in_bin = [bin_map.num_peaks];
total_peaks = sum(num_peaks_in_bin);
num_deconvolved_x = length(bin_map)+total_peaks;
deconvolved.filename = 'not_yet_saved_to_a_file.txt';
deconvolved.input_names = {'Collection ID'    'Type'    'Description' ...
    'Processing log'};
deconvolved.x=1:num_deconvolved_x;
deconvolved.Y=zeros(length(deconvolved.x), num_spectra);
deconvolved.num_samples = num_spectra;
deconvolved.collection_id = '-102';
deconvolved.type = 'SpectraCollection';
deconvolved.description = ['Deconvolved artificially generated spectrum ' ...
    'collection for testing targeted deconvolution'];
deconvolved.processing_log = 'Generated. Deconvolved from first principles.';

% Calculate the deconvolved x values
block_start = 1;
for bin=1:length(bin_map)
    base_id = bin_map(bin).id * 1000;
    deconvolved.x(block_start) = base_id;
    for peak_idx=1:bin_map(bin).num_peaks
        deconvolved.x(block_start + peak_idx) = base_id + peak_idx;
    end
    block_start = block_start + bin_map(bin).num_peaks + 1;
end

% Calculate the deconvolved Y values
for spec=1:num_spectra
    block_start = 1;
    for bin=1:length(bin_map)
        peaks=deconv_peak_obj{bin, spec};
        area_sum = 0;
        for peak_idx=1:length(peaks)
            p=peaks(peak_idx);
            deconvolved.Y(block_start+peak_idx, spec)=p.area;
            area_sum = area_sum + p.area;
        end
        deconvolved.Y(block_start, spec)=area_sum;
        block_start = block_start + bin_map(bin).num_peaks + 1;
    end
end
