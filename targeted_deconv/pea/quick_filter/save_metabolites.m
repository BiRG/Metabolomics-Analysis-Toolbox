function metabolites = save_metabolites(pathname,filename,metabolites)
f = fopen([pathname,filename],'w');

fprintf(f,'ID,Metabolite,Bin (Lt),Bin (Rt),Multiplicity,Deconvolution,Proton ID,ID Source\n');
for i = 1:length(metabolites)
    fprintf(f,'%d,"%s",%f,%f,"%s","%s","%s","%s"\n',metabolites{i}.id,...
        metabolites{i}.metabolite,metabolites{i}.left,...
        metabolites{i}.right,metabolites{i}.multiplicity,...
        metabolites{i}.deconvolution,metabolites{i}.proton_id,...
        metabolites{i}.id_source);
end

fclose(f);
