function [tree,max_q2,n] = build_maximizing_tree(tree)
if ~isempty(tree.left) && ~isempty(tree.right)
    [tree.left,left_q2,left_n] = build_maximizing_tree(tree.left);
    [tree.right,right_q2,right_n] = build_maximizing_tree(tree.right);
    if left_q2+right_q2 > length(tree.Y)*tree.q2 % Is splitting better
        max_q2 = left_q2+right_q2;
        n = left_n+right_n;
    else
        tree.left = {};
        tree.right = {};
        max_q2 = length(tree.Y)*tree.q2;
        n = length(tree.Y);
    end
else
    max_q2 = length(tree.Y)*tree.q2;
    n = length(tree.Y);
end
tree.max_q2 = max_q2;