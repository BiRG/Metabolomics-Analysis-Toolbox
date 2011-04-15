figures_directory_indir = uigetdir([],'Select locations of figures');

if figures_directory_indir == 0
    msgbox(['Invalid directory ',figures_directory_indir]);
    return
end

D = dir(figures_directory_indir);

set(0,'DefaultFigureWindowStyle','docked');
a = [];
for i = 1:length(D)
    if length(D(i).name) >= 4 && strcmp(D(i).name((end-3):end),'.fig')
        open([figures_directory_indir,'/',D(i).name]);
        a(end+1) = gca;
    end    
end
linkaxes(a);
set(0,'DefaultFigureWindowStyle','normal');