function save_state(collections,h,suffix)
indir = uigetdir;
if indir == 0
    msgbox(['Entered invalid directory ',indir]);
    return
end

prompt={'Enter prefix:'};
name='Prefix';
numlines=1  ;
defaultanswer={'state'};
answer=inputdlg(prompt,name,numlines,defaultanswer);
prefix = answer{1};

left_noise_cursor = getappdata(gcf,'left_noise_cursor');
right_noise_cursor = getappdata(gcf,'right_noise_cursor');
if isempty(left_noise_cursor) || isempty(right_noise_cursor)
    left_noise = NaN;
    right_noise = NaN;
else
    left_noise = GetCursorLocation(left_noise_cursor);
    right_noise = GetCursorLocation(right_noise_cursor);
end

for i = 1:length(collections)
    collection_id = num2str(collections{i}.collection_id);
    file = [indir,'\',prefix,'_',collection_id,suffix,'.mat'];
    collection = collections{i};
    [regions,left_handles,right_handles] = get_regions;
    bin_data = {};
    bin_info = {};
    bin_dirty = {};
    bin_old_left = {};
    bin_old_right = {};
    for j = 1:length(left_handles)
        sum_saved_data = getappdata(left_handles(j),'sum_saved_data');
        smart_saved_data = getappdata(left_handles(j),'smart_saved_data');
        adj_saved_data = getappdata(left_handles(j),'adj_saved_data');
        bin_data{j}.all_match_inxs = getappdata(left_handles(j),'all_match_inxs');
        if isempty(sum_saved_data)
            bin_data{j}.sum_saved_data = [];
        else
            bin_data{j}.sum_saved_data = sum_saved_data{i};
        end
        if isempty(smart_saved_data)
            bin_data{j}.smart_saved_data = [];
        else
            bin_data{j}.smart_saved_data = smart_saved_data{i};
        end
        if isempty(adj_saved_data)
            bin_data{j}.adj_saved_data = [];
        else
            bin_data{j}.adj_saved_data = adj_saved_data{i};
        end
        left_handle = left_handles(j);
        info = getappdata(left_handle,'info');
        bin_info{j} = info;
        dirty = getappdata(left_handle,'dirty');
        bin_dirty{j} = dirty;
        old_left = getappdata(left_handle,'old_left');
        bin_old_left{j} = old_left;
        old_right = getappdata(left_handle,'old_right');        
        bin_old_right{j} = old_right;
    end

    save(file,'collection','bin_data','regions','bin_info','bin_dirty','bin_old_left','bin_old_right','left_noise','right_noise');
end