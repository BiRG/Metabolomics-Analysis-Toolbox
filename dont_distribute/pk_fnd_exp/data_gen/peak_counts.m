function counts=peak_counts(spectra)
% Returns a cell array with the number of closer to each x location for each spectrum in spectra than to any other

counts{length(spectra)}=[];
for spec_number=1:length(spectra)
    spec=spectra{spec_number};
    pk_xs=spec.MGPX_BETA(4:4:length(spec.MGPX_BETA));
    

    cur_counts=zeros(1,length(spec.x));
    for pk_num = 1:length(pk_xs)
        x = pk_xs(pk_num);
        dists = abs(spec.x - x);
        [~, idx]=min(dists);
        cur_counts(idx) = cur_counts(idx) + 1;
    end
    
    counts{spec_number} = cur_counts;
end

end