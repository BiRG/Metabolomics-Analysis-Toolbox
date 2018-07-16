function fix_negative_points
%fix_negative_points adjust baseline so that negative points are set to 0.
collections = getappdata(gcf,'collections');
for c = 1:length(collections)
    for s = 1:collections{c}.num_samples
        inds = collections{c}.Y_fixed(:,s) < 0;
        collections{c}.Y_fixed(inds,s) = 0;
        collections{c}.Y_baseline(inds,s) = collections{c}.Y(inds,s) - collections{c}.Y_fixed(inds,s);
    end
end
setappdata(gcf,'collections',collections);
plot_all
end

