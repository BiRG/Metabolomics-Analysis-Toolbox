function set_reference_spectrum(main_h,i,j)
answer = questdlg('Set the reference to this spectrum?','Setting reference','Yes', 'No', 'No');
if strcmp(answer,'Yes')
    collections = getappdata(main_h,'collections');
    collection = collections{i};
    reference = {};
    reference.x = collection.x;
    reference.y = collection.Y(:,j);
    if ~isfield(collection,'spectra')
        [left_noise,right_noise] = get_noise(main_h);
        collections = create_spectra_fields(collections,left_noise,right_noise,get_options(getappdata(main_h,'h_options')),...
            getappdata(main_h,'filtered_list'));
        collection = collections{i};
    end
    reference.X = collection.spectra{j}.xmaxs;
    setappdata(main_h,'reference',reference);
    setappdata(main_h,'collections',collections);
    calling_gcf = gcf;
    figure(main_h);
    plot_all;
    figure(calling_gcf);
end