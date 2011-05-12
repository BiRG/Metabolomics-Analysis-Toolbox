addpath('../matlab_scripts');

num_columns = 2;

collections = load_collections;

[x,Y,labels] = combine_collections(collections);
max_spectrum = Y(:,1)';
min_spectrum = Y(:,1)';
for s = 1:length(labels)
    max_spectrum = max([max_spectrum;Y(:,s)']);
    min_spectrum = min([min_spectrum;Y(:,s)']);
end
    
a = [];
for c = 1:length(collections)
    subplot(ceil(length(collections)/num_columns),num_columns,c);
    [nx,ny] = size(collections{c}.Y);
    for s = 1:ny
        if s ~= 1
            hold on;
        end
        hl = plot(collections{c}.x,collections{c}.Y(:,s),'k');
        myfunc = @(hObject, eventdata, handles) (line_click_info(collections{c},s));
        set(hl,'ButtonDownFcn',myfunc);
    end
    hold off
    legend(collections{c}.description);
    a(c) = gca;
    set(gca,'xdir','reverse');
end
linkaxes(a);

set(0,'DefaultFigureWindowStyle','docked');

a = [];
f = [];
i = 1;
for c = 1:length(collections)
    [sorted_subject_id,inxs] = sort(collections{c}.subject_id);
    for u = 1:length(inxs)
        ui = inxs(u);
        if c == 1
            f(u) = figure;
        else
            figure(f(u));
        end
        
        subplot(length(collections),1,c);
        plot(collections{c}.x,collections{c}.Y(:,ui),'k');
        legend(collections{c}.description);
        set(gca,'xdir','reverse');
        a(i) = gca;
        
        i = i + 1;
        
        set(gcf,'name',num2str(sorted_subject_id(u)));
    end
end
linkaxes(a);

set(0,'DefaultFigureWindowStyle','normal');
