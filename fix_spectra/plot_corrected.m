function plot_corrected()
    
    spectrum_inx = getappdata(gcf,'spectrum_inx');
    collections = getappdata(gcf, 'collections');
    [x, Y] = combine_collections(collections);
    y = Y(:, spectrum_inx);
    
    save('~/Projects/Raman-Tests/in.mat', 'y')
    system('Rscript ~/Projects/Raman-Tests/adjustsignal.R ~/Projects/Raman-Tests/in.mat ~/Projects/Raman-Tests/out.mat')
    load('~/Projects/Raman-Tests/out.mat')
    
    hold on;
    plot(x,background,'b');
    plot(x,y_corrected,'r');
    hold off;
end
