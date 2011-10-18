function Y = adjust_y_deconvolution(collection,bins,deconvolve)
Y = collection.Y;
[num_dp,num_spectra] = size(Y);
for s = 1:num_spectra
    y = collection.Y(:,s);
    try
        y_baseline = collection.y_baseline{s};
        y_fit = collection.y_fit{s};
        y_peaks = y_fit - y_baseline;
        for b = 1:length(deconvolve)
            if deconvolve(b)
                left = bins(b,1);
                right = bins(b,2);
                yinxs = find(left >= collection.x & collection.x >= right);
                BETA = collection.BETA{s};
                X = BETA(4:4:end);
                xinxs = find(left >= X & X > right);
                enabled_xinxs = xinxs(find(collection.include_mask{s}(xinxs) == 1)); % find only those enabled
                xinxs = enabled_xinxs;
                if ~isempty(xinxs)
                    y_bin = global_model(BETA((4*(xinxs(1) - 1)+1):(4*(xinxs(1) - 1)+4)),collection.x(yinxs),1,{});
                    for i = 2:length(xinxs)
                        y_bin = y_bin + global_model(BETA((4*(xinxs(i) - 1)+1):(4*(xinxs(i) - 1)+4)),collection.x(yinxs),1,{});
                    end
                    Y(yinxs,s) = y(yinxs) - y_peaks(yinxs) - y_baseline(yinxs) + y_bin';
                else
                    Y(yinxs,s) = y(yinxs) - y_peaks(yinxs) - y_baseline(yinxs);
                end
            end
        end
    catch ME % there was an error, which probably means that the deconvolution wass not completed
    end
end