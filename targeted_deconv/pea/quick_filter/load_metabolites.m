function metabolites = load_metabolites(pathname,filename)
bm = load_binmap(fullfile(pathname, filename));

metabolites = cell(1,length(bm));

for i = 1:length(bm)
    metabolites{i}.id = bm(i).id;
    metabolites{i}.metabolite = bm(i).compound_descr;
    metabolites{i}.left = bm(i).bin.left;
    metabolites{i}.right = bm(i).bin.right;
    metabolites{i}.multiplicity = bm(i).multiplicity;
    if bm(i).is_clean
        metabolites{i}.deconvolution = 'Clean';
    else
        metabolites{i}.deconvolution = 'Overlap';
    end
    metabolites{i}.proton_id = bm(i).proton_id;
    metabolites{i}.id_source = bm(i).id_source;
end
