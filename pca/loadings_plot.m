%% Update loadings plot
function loadings_plot(handles, x_pc_inx)
axes(handles.loadings_axes);
[~,inxs] = sort(abs(handles.model.coeff(:,x_pc_inx)),'descend');
h = bar(handles.model.coeff(inxs,x_pc_inx));
set(h,'EdgeColor','k');
set(h,'FaceColor','k');
ylabel(['PC_',num2str(x_pc_inx),' Loading'],'Interpreter','tex');
set(gca,'XTickLabel',{});
xlabel('Variable');
end