function spec = artificial_test_dilution_spec_1( )
% Return first simple artificial spectrum collection for testing dilution routines
%
% spec = ARTIFICIAL_TEST_DILUTION_SPEC_1( )
%
%   Makes 20 artificial spectra composed of a group of sine waves randomly
%   shifted and modified by an envelope function. This envelope function
%   ensures that the first and last 30 points are 0. The resulting spectrum
%   has an x range of 0..11 and a maximum of about 72. Then these are divided by
%   1:4:80 to "dilute" them and finally gaussian noise of 0.01 standard
%   deviation is added.

% Save the current random stream and make this repeatable by creating our
% own stream
oldRandStr = RandStream.getDefaultStream;
randStr=RandStream('mt19937ar','Seed',387120130);
RandStream.setDefaultStream(randStr);

% X coordinates to use for the unshifted sine waves
x=1:pi/16:1000;

% Choose 1 out of every 32 x values as a point which will have a random
% shift value
shift_points = x(1:32:length(x));

% Choose the phase shift at that point
raw_shifts = randn(length(shift_points),20);

% Interpolate the rest of the shifts so that the sine waves vary smoothly
% in frequency (otherwise it would look choppy with many very high
% frequency components)
shifts = interp1(shift_points,raw_shifts,x,'spline');

% Calculate the points at which the sines will be taken - x values plus
% shifts
sin_points = repmat(x',1,20)+shifts;

% Calculate dilution factors
dilution_factors = 1./(1:4:80);
dilution_factors = repmat(dilution_factors,length(x),1);

% Calculate noise
noise = randn(length(x),20).*0.01;

% Calculate an envelope to make the first 30 and last 30 points 0 and the
% the envelope to increase linearly to 1 for the second 30 and
% second-to-last 30 points.
make_baseline_env = [zeros(1,30),linspace(0,1,30),ones(1,length(x)-120),linspace(1,0,30),zeros(1,30)]';
make_baseline_env = repmat(make_baseline_env,1,20);

% Calculate an envelope to make two big signal regions and a smaller small
% signal region
signal_region_env = repmat(((sin(x/180)+sin(x/120)).^2)',1,20);

% Calculate the shifted sine waves
shifted_sines = (sin(sin_points)+1).*10;

% Calculate the y values from the components
y=shifted_sines.*signal_region_env.*dilution_factors.*make_baseline_env+noise;

% Package everything into a spectrum structure - then into a collections
% cell array
spec.input_names = {'Collection ID', 'Type', 'Description', 'Processing log', 'Base sample ID', 'Time', 'Classification', 'Sample ID', 'Subject ID', 'Sample Description', 'Weight', 'Units of weight', 'Species'};
spec.formatted_input_names = {'collection_id', 'type', 'description', 'processing_log', 'base_sample_id', 'time', 'classification', 'sample_id', 'subject_id', 'sample_description', 'weight', 'units_of_weight', 'species'};
spec.collection_id='-1101';
spec.type='SpectraCollection';
spec.description='Collection for testing normalization routines.';
spec.processing_log='Created artificial spectrum.';
spec.time=zeros(1,20);
spec.classification=arrayfun(@(x) sprintf('%f',(1/x)),dilution_factors(1,:),'UniformOutput',false); % Classify by dilution factor
spec.sample_id=1:20;
spec.subject_id=1:20;
spec.sample_description=spec.classification;
spec.weight=ones(1,20);
spec.units_of_weight=arrayfun(@(x) 'Stone',1:20,'UniformOutput',false);
spec.species=arrayfun(@(x) 'Gray Alien',1:20,'UniformOutput',false);
spec.x=linspace(0,11,length(x)); 
spec.Y=y; 
spec.num_samples=20; 
spec.base_sample_id=1:20;
spec = {spec};


% Replace the original random stream
RandStream.setDefaultStream(oldRandStr);

end

