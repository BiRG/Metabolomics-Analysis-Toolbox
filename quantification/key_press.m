function key_press(main_h,main_ax)
collections = getappdata(main_h,'collections');
if isempty(collections)
    return
end

k = get(main_h,'CurrentKey');

if strcmp(k,'uparrow') % Prev max
    ylim1 = get(gca,'ylim');
    diff = ylim1(2)-ylim1(1);
    set(gca,'ylim',[ylim1(1)+diff*0.1,ylim1(2)+diff*0.1]);
elseif strcmp(k,'downarrow') % Next max
    ylim1 = get(gca,'ylim');
    diff = ylim1(2)-ylim1(1);
    set(gca,'ylim',[ylim1(1)-diff*0.1,ylim1(2)-diff*0.1]);
elseif strcmp(k,'rightarrow')
    xlim1 = get(gca,'xlim');
    xdist = getappdata(main_h,'xdist');
    if isempty(xdist)
        xdist = 0.005;
    end
    set(gca,'xlim',[xlim1(1)-xdist,xlim1(2)-xdist]);        
elseif strcmp(k,'leftarrow')
    xlim1 = get(gca,'xlim');
    xdist = getappdata(main_h,'xdist');
    if isempty(xdist)
        xdist = 0.005;
    end
    set(gca,'xlim',[xlim1(1)+xdist,xlim1(2)+xdist]);    
elseif strcmp(k,'pageup')
    xlim1 = get(gca,'xlim');
    xdist = getappdata(main_h,'xdist');
    if isempty(xdist)
        xdist = 0.005;
    end
    set(gca,'xlim',[xlim1(1)-xdist,xlim1(2)+xdist]);
elseif strcmp(k,'b')
    max_spectrum = getappdata(main_h,'max_spectrum');
    min_spectrum = getappdata(main_h,'min_spectrum');
    x = getappdata(main_h,'x');
    regions = get_regions;
    nm = size(regions);
    centers = [];
    for i = 1:nm(1)
        centers(end+1) = mean(regions(i,:));
    end
    bin_center = input('Enter center of bin: ');    
    [v,ix] = min(abs(centers-bin_center));    
    inxs = find(regions(ix,1) >= x & x >= regions(ix,2));
    mx = max(max_spectrum(inxs));
    mn = min(min_spectrum(inxs));
    xlim([regions(ix,2),regions(ix,1)]);
    ylim([mn,mx]);
elseif strcmp(k,'pagedown')
    xlim1 = get(gca,'xlim');
    xdist = getappdata(main_h,'xdist');
    if isempty(xdist)
        xdist = 0.005;
    end
    set(gca,'xlim',[xlim1(1)+xdist,xlim1(2)-xdist]);
elseif strcmp(k,'home')
    ylim1 = get(gca,'ylim');
    set(gca,'ylim',[ylim1(1)*1.1,ylim1(2)*1.1]);
elseif strcmp(k,'end')
    ylim1 = get(gca,'ylim');
    set(gca,'ylim',[ylim1(1)*0.9,ylim1(2)*0.9]);
elseif strcmp(k,'u')
    orig_ylim = getappdata(main_h,'orig_ylim');
    yl = get(gca,'ylim');
    xl = get(gca,'xlim');
    fhs = getappdata(main_h,'fhs');
    for i = 1:length(fhs)
        ax = get(fhs(i),'CurrentAxes');
        set(ax,'ylim',yl);
        set(ax,'xlim',xl);
        %% Extras        
        figure(fhs(i));
        extra_hs = getappdata(fhs(i),'extra_hs');
        for j = 1:length(extra_hs)
            delete(extra_hs);
        end
        extra_hs = [];
        setappdata(fhs(i),'extra_hs',extra_hs);
    end
    figure(main_h);
elseif strcmp(k,'r')
    xlim auto
    ylim auto
end
%     if isempty(getappdata(gcf,'bin_inx'))
%         setappdata(gcf,'bin_inx',0);        
%     end
%     bin_inx = getappdata(gcf,'bin_inx');
%     bin_inx = bin_inx + 1;
%     if bin_inx > num_bins
%         bin_inx = bin_inx - 1;
%     else
%         left = get(bins_cursors(bin_inx,1),'xdata');%GetCursorLocation(gcf,bins_cursors(bin_inx,1));
%         left = left(1);
%         right = get(bins_cursors(bin_inx,2),'xdata');%GetCursorLocation(gcf,bins_cursors(bin_inx,2));
%         right = right(1);
%         set(gca,'xlim',[right,left]);
%         ymax = -Inf;
%         ymin = Inf;
%         for c = 1:length(collections)
%             inxs = find(left >= collections{c}.x & collections{c}.x >= right);
%             for s = 1:collections{c}.num_samples
%                 mx = max(collections{c}.Y(inxs,s));
%                 if mx > ymax
%                     ymax = mx;
%                 end
%                 mn = min(collections{c}.Y(inxs,s));
%                 if mn < ymin
%                     ymin = mn;
%                 end
%             end
%         end
%         set(gca,'ylim',[ymin,ymax]);
%     end
%     setappdata(gcf,'bin_inx',bin_inx);
% elseif strcmp(k,'leftarrow')
%     if isempty(getappdata(gcf,'bin_inx'))
%         setappdata(gcf,'bin_inx',0);        
%     end
%     bin_inx = getappdata(gcf,'bin_inx');
%     bin_inx = bin_inx - 1;
%     if bin_inx < 1
%         bin_inx = bin_inx + 1;
%     else
%         left = get(bins_cursors(bin_inx,1),'xdata');%GetCursorLocation(gcf,bins_cursors(bin_inx,1));
%         left = left(1);
%         right = get(bins_cursors(bin_inx,2),'xdata');%GetCursorLocation(gcf,bins_cursors(bin_inx,2));
%         right = right(1);
%         set(gca,'xlim',[right,left]);
%         ymax = -Inf;
%         ymin = Inf;
%         for c = 1:length(collections)
%             inxs = find(left >= collections{c}.x & collections{c}.x >= right);
%             for s = 1:collections{c}.num_samples
%                 mx = max(collections{c}.Y(inxs,s));
%                 if mx > ymax
%                     ymax = mx;
%                 end
%                 mn = min(collections{c}.Y(inxs,s));
%                 if mn < ymin
%                     ymin = mn;
%                 end
%             end
%         end
%         set(gca,'ylim',[ymin,ymax]);
%     end
%     setappdata(gcf,'bin_inx',bin_inx);
% end