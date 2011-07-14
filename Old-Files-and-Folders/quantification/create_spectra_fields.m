function collections = create_spectra_fields(collections,left_noise,right_noise,options,percentile)
[x,Y,labels] = combine_collections(collections);
if exist('percentile')
    spectra = create_spectra(x,Y,left_noise,right_noise,options,percentile);
else
    spectra = create_spectra(x,Y,left_noise,right_noise,options);
end
i = 1;
for c = 1:length(collections)
    if ~isfield(collections{c},'spectra') % Only if there isn't already on there
        collections{c}.spectra = {};
        for s = 1:collections{c}.num_samples
            spectrum = spectra{i};
            spectrum.xmaxs = x(spectrum.all_maxs);
            spectrum.xmins = x(spectrum.all_mins);
            spectrum = rmfield(spectrum,'all_mins');
            spectrum = rmfield(spectrum,'all_maxs');
            collections{c}.spectra{s} = spectrum;
            i = i + 1;
        end
    end
end
