function plot_corrected()
    
    spectrum_inx = getappdata(gcf,'spectrum_inx');
    collections = getappdata(gcf, 'collections');
    [x, Y] = combine_collections(collections);
    y = Y(:, spectrum_inx);
    
    save('raman_scripts/raman_in.mat', 'y');
    system('Rscript raman_scripts/adjustsignal.R raman_scripts/raman_in.mat raman_scripts/raman_out.mat');
    load('raman_scripts/raman_out.mat');
    
    delete('raman_scripts/raman_in.mat', 'raman_scripts/raman_out.mat');
    
    hold on;
    plot(x,background,'b');
    plot(x,y_corrected,'r');
    hold off;
end
