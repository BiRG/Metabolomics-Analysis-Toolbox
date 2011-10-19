function Y = adjust_y_deconvolution(collection,bins,deconvolve)
Y = collection.Y;
x = collection.x;
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
                yinxs = collection.regions{s}{b}.inxs;
                BETA = collection.regions{s}{b}.BETA0;
                xinxs = find(left >= x(collection.maxs{s}) & x(collection.maxs{s}) > right);
                if sum(abs(collection.maxs{s}(xinxs) - collection.regions{s}{b}.maxs)) > 0
                    msgbox('Something unexpected has changed in regards to the location of the peaks');
                    return;
                end
                enabled_xinxs = find(collection.include_mask{s}(xinxs) == 1); % find only those enabled
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
    catch ME % there was an error, which probably means that the deconvolution was not completed
        Y = collection.Y;
        fprintf('Nothing adjusted.\n');
        return;
    end
end