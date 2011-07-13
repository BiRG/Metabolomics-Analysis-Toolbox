% --- Executes on button press in deconvolution_button.
function deconvolution_button_Callback(hObject, eventdata, handles)
% hObject    handle to deconvolution_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

append_to_log(handles,sprintf('Starting deconvolution'));

collection = getappdata(gcf,'collection');
[num_variables,num_spectra] = size(collection.Y);
if ~isfield(collection,'maxs')
    msgbox('Find peaks before running deconvolution');
    return
end
% First time
if isempty(find(collection.BETA{1}(1:4:end) ~= 0))
    collection.x_baseline_BETA = {};
    collection.baseline_BETA = {};
    collection.y_baseline = {};
    collection.y_fit = {};
    collection.dirty = [];
    collection.dirty(1:length(collection.BETA)) = true;
end
% Perform deconvolution
for s = 1:num_spectra
    x = collection.x;
    xwidth = collection.x(1) - collection.x(2);
    maxs = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;
    if ~getappdata(gcf,'dirty') && ~collection.dirty(s) % Check if anything changed
        append_to_log(handles,sprintf('No deconvolution required for spectrum %d/%d',s,num_spectra));
        continue;
    end
    % A peak has been added
    prev_BETA = collection.BETA{s};
    prev_maxs = maxs;
    if length(maxs) ~= length(collection.maxs{s}) && ~isempty(maxs)
        collection.BETA{s} = []; % Reinitialize
    end
    options = {};
    options.min_width = round(str2num(get(handles.min_width_edit,'String'))/xwidth);
    options.max_width = round(str2num(get(handles.max_width_edit,'String'))/xwidth);
    options.num_iterations = round(str2num(get(handles.num_iterations_edit,'String')));
    % Only optimize those peaks within the current zoom
    xl = xlim;
    X = collection.x(collection.maxs{s});
    m_inxs = find(xl(1) <= X & X <= xl(2));
    if ~isempty(m_inxs)
        stdin = create_hadoop_input(collection.x',collection.Y(:,s),collection.maxs{s}(m_inxs),collection.mins{s}(m_inxs,:),[],options);
%         scpfrommatlab('w100pea','localhost','localhost','birglab!','hadoop_input.txt','deconvolution/hadoop_input.txt')

%             fid = fopen('hadoop_input.txt','r');
%             stdin = char(fread(fid,[1,Inf],'char'));
%             fclose(fid);

        stdin = mapper(stdin,[]);

%             fid = fopen('mapper_output.txt','r');
%             stdin = char(fread(fid,[1,Inf],'char'));
%             fclose(fid);

        options = {};
        options.baseline_width = str2num(get(handles.baseline_width_edit,'String'));
        options.min_width = round(str2num(get(handles.min_width_edit,'String'))/xwidth);
        options.max_width = round(str2num(get(handles.max_width_edit,'String'))/xwidth);
        options.num_generations = 100;
        o_inxs = find(collection.x(prev_maxs) < xl(1) | collection.x(prev_maxs) > xl(2)); % Find only those outside of the region
        o_prev_BETA = [];
        for q = 1:length(o_inxs)
            o_prev_BETA = [o_prev_BETA;prev_BETA(4*(o_inxs(q)-1)+(1:4))];
        end
        results = reducer(collection.x',collection.Y(:,s),stdin,o_prev_BETA,collection.x(prev_maxs(o_inxs)),options);
        collection.BETA{s} = results.BETA;
        collection.y_fit{s} = results.solution.y_fit;
        collection.x_baseline_BETA{s} = results.x_baseline_BETA;
%             collection.baseline_BETA{s} = results.baseline_BETA;
        collection.y_baseline{s} = results.y_baseline;
        collection.dirty(s) = false;

        % Update the max indices
        collection.maxs{s} = round((x(1) - collection.BETA{s}(4:4:end)')/xwidth)+1;

        append_to_log(handles,sprintf('Finished spectrum %d/%d',s,num_spectra));
    else
        append_to_log(handles,sprintf('No peaks within current zoom for spectrum %d/%d',s,num_spectra));
    end
end
setappdata(gcf,'collection',collection);
setappdata(gcf,'dirty',false);

refresh_axes2(handles);

append_to_log(handles,sprintf('Finished deconvolution'));

