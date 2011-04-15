function click_menu(main_h, main_ax)

str = {'Get collections','Load collections','Load state'};
% str = {str{:},'','Set noise regions'};
str = {str{:},'','Load bins','Create new bin','Load noise region','Set noise region','Dynamic adaptive bin','Find peaks','Load reference'};
str = {str{:},'','Save noise region','Save bins','Save collections','Post collections','Save state','Save reference'};
str = {str{:},'','Set zoom x distance','Set zoom y distance'};
[s,v] = listdlg('PromptString','Select an action',...
              'SelectionMode','single',...
              'ListString',str);

if isempty(s)
    return
end

if strcmp(str{s},'Load collections')
    loaded_collections = getappdata(main_h,'collections'); 
    
    collections = load_collections;
    if isempty(collections)
        return
    end
    if ~isempty(loaded_collections)
        collections = {loaded_collections{:},collections{:}};
    end

    [x,Y,labels] = combine_collections(collections);
    max_spectrum = Y(:,1)';
    min_spectrum = Y(:,1)';
    for s = 1:length(labels)
        max_spectrum = max([max_spectrum;Y(:,s)']);
        min_spectrum = min([min_spectrum;Y(:,s)']);
    end
    setappdata(main_h,'x',x);
    setappdata(main_h,'Y',Y);
    setappdata(main_h,'max_spectrum',max_spectrum');
    setappdata(main_h,'min_spectrum',min_spectrum');
    
    cnt = 1;
    for c = 1:length(collections)
        c_Y = zeros(length(x),collections{c}.num_samples);
        for s = 1:collections{c}.num_samples
            c_Y(:,s) = Y(:,cnt);
            cnt = cnt + 1;
        end
        collections{c}.x = x;
        collections{c}.Y = c_Y;
        collections{c}.Y_fixed = zeros(size(collections{c}.Y));
        collections{c}.Y_baseline = zeros(size(collections{c}.Y));        
        if isfield(collections{c},'spectra')
            collections{c} = rmfield(collections{c},'spectra');
        end
    end
    setappdata(main_h,'collections',collections);
    
    plot_all;
    setappdata(main_h,'orig_ylim',get(main_ax,'ylim'));
elseif strcmp(str{s},'Find peaks')
    left_noise_cursor = getappdata(gcf,'left_noise_cursor');
    right_noise_cursor = getappdata(gcf,'right_noise_cursor');
    if isempty(left_noise_cursor) || isempty(right_noise_cursor)
        msgbox('Set the noise cursors');
        return
    end
    left_noise = GetCursorLocation(left_noise_cursor);
    right_noise = GetCursorLocation(right_noise_cursor);
    if right_noise > left_noise
        t = left_noise;
        left_noise = right_noise;
        right_noise = t;
    end
    collections = getappdata(gcf,'collections');
    collections = create_spectra_fields(collections,left_noise,right_noise);
    setappdata(gcf,'collections',collections);
elseif strcmp(str{s},'Dynamic adaptive bin')
    dynamic_adaptive_bin_helper;
elseif strcmp(str{s},'Adaptive bin')
    adaptive_bin_helper;
elseif strcmp(str{s},'Adaptive intelligent bin')
    adaptive_intelligent_bin_helper;
elseif strcmp(str{s},'Load noise region')
    [filename,pathname] = uigetfile('*.txt', 'Load noise region');
    file = fopen([pathname,filename],'r');
    myline = fgetl(file);
    fields = split(myline,',');
    left_noise = str2num(fields{1});
    right_noise = str2num(fields{2});
    if ~isempty(getappdata(gcf,'left_noise_cursor'))
        DeleteCursor(getappdata(gcf,'left_noise_cursor'));
    end
    if ~isempty(getappdata(gcf,'right_noise_cursor'))
        DeleteCursor(getappdata(gcf,'right_noise_cursor'));
    end   
    left_noise_cursor = CreateCursor(gcf,'k');
    SetCursorLocation(left_noise_cursor,left_noise);
    right_noise_cursor = CreateCursor(gcf,'k');
    SetCursorLocation(right_noise_cursor,right_noise);
    setappdata(gcf,'left_noise_cursor',left_noise_cursor);
    setappdata(gcf,'right_noise_cursor',right_noise_cursor);    
elseif strcmp(str{s},'Save noise region')
    left_noise_cursor = getappdata(gcf,'left_noise_cursor');
    right_noise_cursor = getappdata(gcf,'right_noise_cursor');
    if isempty(left_noise_cursor) || isempty(right_noise_cursor)
        left_noise = NaN;
        right_noise = NaN;
    else
        left_noise = GetCursorLocation(left_noise_cursor);
        right_noise = GetCursorLocation(right_noise_cursor);
    end
    if ~isnan(left_noise) && ~isnan(right_noise)
        [filename,pathname] = uiputfile('*.txt', 'Save regions');
        file = fopen([pathname,filename],'w');
        fprintf(file,'%f,%f',left_noise,right_noise);
        fclose(file);
    end
elseif strcmp(str{s},'Set noise region')
    set_noise_regions;    
elseif strcmp(str{s},'Get collections')
    loaded_collections = getappdata(main_h,'collections'); 
    collections = get_collections;
    if ~isempty(loaded_collections)
        collections = {loaded_collections{:},collections{:}};
    end
    for c = 1:length(collections)
        collections{c}.Y_fixed = zeros(size(collections{c}.Y));
        collections{c}.Y_baseline = zeros(size(collections{c}.Y));
    end
    setappdata(main_h,'collections',collections);
    plot_all;
    setappdata(main_h,'orig_ylim',get(main_ax,'ylim'));    
    [x,Y,labels] = combine_collections(collections);
    max_spectrum = Y(:,1)';
    min_spectrum = Y(:,1)';
    for s = 1:length(labels)
        max_spectrum = max([max_spectrum;Y(:,s)']);
        min_spectrum = min([min_spectrum;Y(:,s)']);
    end
    setappdata(main_h,'x',x);
    setappdata(main_h,'Y',Y);
    setappdata(main_h,'max_spectrum',max_spectrum');
    setappdata(main_h,'min_spectrum',min_spectrum');
elseif strcmp(str{s},'Set noise regions')
    set_noise_regions;
elseif strcmp(str{s},'Edit bin')
    set_edit
elseif strcmp(str{s},'Show bin')
    show_bin
elseif strcmp(str{s},'Create new bin')
    create_new
elseif strcmp(str{s},'Delete bin')
    delete_region
elseif strcmp(str{s},'Save bins')
    save_regions
elseif strcmp(str{s},'Load bins')
    load_regions
elseif strcmp(str{s},'Save collections')
    collections = getappdata(main_h,'collections');
    [regions,left_handles] = get_regions;
    for c = 1:length(collections)
        collection = bin_collection(main_h,collections,c,left_handles);
        save_collections({collection},'_binned');
    end
elseif strcmp(str{s},'Post collections')
    collections = getappdata(main_h,'collections');
    [regions,left_handles] = get_regions;
    prompt={'Analysis ID:'};
    name='Enter the analysis ID from the website';
    numlines=1;
    defaultanswer={''};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    analysis_id = answer{1};        
    for c = 1:length(collections)
        collection = bin_collection(main_h,collections,c,left_handles);
        post_collections(main_h,{collection},'_binned',analysis_id);
    end
elseif strcmp(str{s},'Set zoom x distance')
    prompt={'x distance:'};
    name='Set zoom x distance';
    numlines=1  ;
    defaultanswer={'0.005'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    setappdata(main_h,'xdist',str2num(answer{1}));
elseif strcmp(str{s},'Set zoom y distance')
    prompt={'y distance:'};
    name='Set zoom y distance';
    numlines=1;
    collections = getappdata(main_h,'collections');
    [x,Y,labels] = combine_collections(collections);
    max_spectrum = Y(:,1)';
    min_spectrum = Y(:,1)';
    for s = 1:length(labels)
        max_spectrum = max([max_spectrum;Y(:,s)']);
        min_spectrum = min([min_spectrum;Y(:,s)']);
    end
    ydist = max(max_spectrum)*0.005;    
    defaultanswer={num2str(ydist)};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    setappdata(main_h,'ydist',str2num(answer{1}));
elseif strcmp(str{s},'Save state')
    collections = getappdata(main_h,'collections');
    save_state(collections,main_h,'_quantification');
elseif strcmp(str{s},'Load state')
    loaded_collections = getappdata(main_h,'collections');     
    collection = load_state;
    if isempty(collection)
        return;
    end
    if ~isempty(loaded_collections)
        collections = {loaded_collections{:},collection};
    else
        collections = {collection};
    end
    for c = 1:length(collections)
        collections{c}.Y_fixed = zeros(size(collections{c}.Y));
        collections{c}.Y_baseline = zeros(size(collections{c}.Y));
    end
    setappdata(main_h,'collections',collections);
    plot_all;
    setappdata(main_h,'orig_ylim',get(main_ax,'ylim'));    
elseif strcmp(str{s},'Save reference')
    [filename, pathname] = uiputfile('*.mat', 'Save reference as');
    reference = getappdata(main_h,'reference');
    save([pathname,filename],'reference');
elseif strcmp(str{s},'Load reference')
    [filename, pathname] = uigetfile('*.mat', 'Load reference');
    load([pathname,filename]);
    setappdata(main_h,'reference',reference);
    plot_all;
end