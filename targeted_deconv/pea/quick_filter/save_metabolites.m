function metabolites = save_metabolites(pathname,filename,metabolites)
f = fopen([pathname,filename],'w');

fprintf(f,'ID,Metabolite,Bin (Lt),Bin (Rt),Multiplicity\n');
for i = 1:length(metabolites)
    fprintf(f,'%d,%s,%f,%f,%s\n',metabolites{i}.id,...
        metabolites{i}.metabolite,metabolites{i}.left,...
        metabolites{i}.right,metabolites{i}.multiplicity);
end

fclose(f);
