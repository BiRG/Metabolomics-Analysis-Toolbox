function is_noisy = noise_samples(collection, num_baseline_pts, num_std_dev)
% Return a list of the samples that can be qualified as noise in some spectrum in the collection
%
% For each spectrum, calculates the standard deviation of the first
% num_baseline_pts points. num_std_dev times that value is taken as
% threshold for that spectrum. Any sample less than the threshold is a
% noisy point in that spectrum. And any sample that is noisy in any
% spectrum is marked true in the return value is_noisy. All other samples
% are marked false.
% 
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collection       - a struct with a field called Y that holds a numeric 
%                    matrix. Each row holds the data for a sample at a 
%                    particular ppm. Each column holds the data for a 
%                    single spectrum.
%
% num_baseline_pts - scalar - number of points that will be used to 
%                    calculate the standard deviation of the noise. See 
%                    description. Must be 1 or greater.
%
% num_std_dev      - scalar - the threshold for a given spectrum is set to
%                    num_std_dev * noise_standard_dev where the noise
%                    standard deviation is calculated using
%                    num_baseline_pts. See description. Must be 0 or 
%                    greater.
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% is_noisy - column vector of logical, 1 for each row of collection.Y. True
%            iff the algorithm detected that the point was noisy in any
%            spectrum. See description.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.Y=[1,1,1;2,2,2;1,1,1;4,5,6;7,8,9;2,3,4;4,3,2;5,5,5]; noise_samples(f,3,5)
%
% ans = [1;1;1;0;0;1;1;0]
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

assert(isstruct(collection), 'noise_samples:struct', ...
    'The collection passed to noise_samples must be a struct.');

assert(isfield(collection,'Y'), 'noise_samples:Y_field', ...
    'The collection passed to noise_samples must have a field named ''Y''.');

assert(num_baseline_pts >= 1, 'noise_samples:num_baseline_pts', ...
    'num_baseline_pts passed to noise_samples must be 1 or more.');

assert(num_baseline_pts <= size(collection.Y,1), ...
    'noise_samples:num_baseline_pts_too_large', ...
    'num_baseline_pts cannot be more than the number of samples in a spectrum.');

assert(num_std_dev >= 0, 'noise_samples:num_std_dev', ...
    'num_std_dev passed to noise_samples must not be negative');

threshold = num_std_dev .* std(collection.Y(1:num_baseline_pts, :), 0, 1);
threshold = repmat(threshold, size(collection.Y,1), 1);
is_noisy = collection.Y <= threshold;
is_noisy = any(is_noisy, 2); % At least one item in row is under threshold

end

