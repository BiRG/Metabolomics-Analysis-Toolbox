function create_plot_from_tree(tree,width,loc)

if ~isempty(tree.left) || ~isempty(tree.right)
    if loc == 0 % Start
        plot(loc,[tree.q2,tree.q2],'o','MarkerSize',10,'MarkerFaceColor','k');
    end
    plot(loc+[-width/2,width/2],[tree.q2,tree.q2],':k');
end

if ~isempty(tree.left)
    x = loc+[-width/2,-width/2];
    y = [tree.q2,tree.left.q2];
%     plot(x,y,'k-');
    h = arrow([x(1),y(1)],[x(2),y(2)]);
    arrow([x(1),y(1)],[x(2),y(2)]);
    delete(h);
    create_plot_from_tree(tree.left,width/2,loc-width/2);
    if isempty(tree.left.left) && isempty(tree.left.right)
        text(x(2),y(2),sprintf(' %d',length(tree.left.Y)));
    end
end
if ~isempty(tree.right)
    x = loc+[width/2,width/2];
    y = [tree.q2,tree.right.q2];
%     plot(x,y,'k-');
    h = arrow([x(1),y(1)],[x(2),y(2)]);
    arrow([x(1),y(1)],[x(2),y(2)]);
    delete(h);
    create_plot_from_tree(tree.right,width/2,loc+width/2);
    if isempty(tree.right.left) && isempty(tree.right.right)
        text(x(2),y(2),sprintf(' %d',length(tree.right.Y)));
    end
end