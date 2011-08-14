addpath('../common_scripts');

num_columns = 2;

collections = load_collections;

collection = collections{1};

handles = {};
handles.collection = collection;
[sorted_str,group_by_inxs,inxs] = by_classification_pushbutton(handles);
group_by_inxs = {group_by_inxs{inxs}};

a = [];
for g = 1:length(group_by_inxs)
    subplot(ceil(length(sorted_str)/num_columns),num_columns,g);
    ginxs = group_by_inxs{g};
    for i = 1:length(ginxs)
        if i ~= 1
            hold on;
        end
        s = ginxs(i);
        hl = plot(collection.x,collection.Y(:,s),'k');
        myfunc = @(hObject, eventdata, handles) (line_click_info(collection,s));
        set(hl,'ButtonDownFcn',myfunc);
    end
    hold off
    legend(sorted_str{g});
    a(g) = gca;
    set(gca,'xdir','reverse');
end
linkaxes(a);

% Load bins
[filename, pathname] = uigetfile('*.txt', 'Pick a bin file');
fid = fopen([pathname,filename],'r');
line = fgetl(fid);
fclose(fid);
bins = [];
fields = split(line,';');
for i = 1:length(fields)
    left_right = split(fields{i},',');
    bins(i,1) = str2num(left_right{1});
    bins(i,2) = str2num(left_right{2});
end
[filename, pathname] = uigetfile('*.xlsx', 'Pick a loadings file');


% set(0,'DefaultFigureWindowStyle','docked');
% 
% a = [];
% f = [];
% i = 1;
% for c = 1:length(collections)
%     [sorted_subject_id,inxs] = sort(collections{c}.subject_id);
%     for u = 1:length(inxs)
%         ui = inxs(u);
%         if c == 1
%             f(u) = figure;
%         else
%             figure(f(u));
%         end
%         
%         subplot(length(collections),1,c);
%         plot(collections{c}.x,collections{c}.Y(:,ui),'k');
%         legend(collections{c}.description);
%         set(gca,'xdir','reverse');
%         a(i) = gca;
%         
%         i = i + 1;
%         
%         set(gcf,'name',num2str(sorted_subject_id(u)));
%     end
% end
% linkaxes(a);
% 
% set(0,'DefaultFigureWindowStyle','normal');
