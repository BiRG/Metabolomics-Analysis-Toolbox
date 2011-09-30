function metabolites = load_metabolites(pathname,filename)
mm = load_metabmap(fullfile(pathname, filename));

metabolites = cell(1,length(mm));

for i = 1:length(mm)
    metabolites{i}.id = mm(i).id;
    metabolites{i}.metabolite = mm(i).compound_descr;
    metabolites{i}.left = mm(i).bin.left;
    metabolites{i}.right = mm(i).bin.right;
    metabolites{i}.multiplicity = mm(i).multiplicity;
    if mm(i).is_clean
        metabolites{i}.deconvolution = 'Clean';
    else
        metabolites{i}.deconvolution = 'Overlap';
    end
    metabolites{i}.proton_id = mm(i).proton_id;
    metabolites{i}.id_source = mm(i).id_source;
end
