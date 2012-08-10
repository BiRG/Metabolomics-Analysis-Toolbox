function noise_std = noise_for_snr( collection, snr )
% Return the standard deviation of the noise to add to achieve a given SNR
%
% Returns an array. If noise with the standard deviation given in
% noise_std(i) is added to spectrum i in the collection, the result will
% have a signal-to-noise-ratio snr (assuming that spectrum i is all signal
% with no noise)
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collection - a struct with a field called Y that holds a numeric array.
%              The columns are spectra.
%
% snr        - a scalar holding the target signal to noise ratio
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% noise_std - if you add noise to collection.Y(:,i) and the standard
%             deviation of the noise is noise_std(i) and collection.Y(:,i)
%             is noiseless, then the signal-to-noise ratio of the result
%             will be snr.
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.Y=[1,2,4; 10,2,4; 1,20,4]; noise_for_snr( f, 2 )
%
% ans = [5, 10, 2]
% 
%     
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

assert(isstruct(collection), 'noise_for_snr:struct', ...
    'The collection passed to noise_for_snr must be a struct.');

assert(isfield(collection,'Y'), 'noise_for_snr:Y_field', ...
    'The collection passed to noise_for_snr must have a field named ''Y''.');

assert(snr > 0, 'noise_for_snr:pos_snr', ...
    'The signal to noise ratio must be greater than 0.');

noise_std = max(collection.Y,[],1) ./ snr;

end

