function metabolites = load_metabolites(pathname,filename)
metabolites = {};
[NUMERIC,TXT,RAW] = xlsread([pathname,filename]);
x_inx = find(strcmpi({TXT{1,:}},'ID'));
m_inx = find(strcmpi({TXT{1,:}},'Metabolite'));
left_inx = find(strcmpi({TXT{1,:}},'Bin (Lt)'));
right_inx = find(strcmpi({TXT{1,:}},'Bin (Rt)'));
multiplicity_inx = find(strcmpi({TXT{1,:}},'multiplicity'));
d_inx = find(strcmpi({TXT{1,:}},'deconvolution'));
p_inx = find(strcmpi({TXT{1,:}},'Proton ID'));
id_source_inx = find(strcmpi({TXT{1,:}},'ID Source'));

for i = 1:size(RAW,1)-1
    metabolites{i}.id = RAW{i+1,x_inx};
    metabolites{i}.metabolite = RAW{i+1,m_inx};
    metabolites{i}.left = RAW{i+1,left_inx};
    metabolites{i}.right = RAW{i+1,right_inx};
    metabolites{i}.multiplicity = RAW{i+1,multiplicity_inx};
    metabolites{i}.deconvolution = RAW{i+1,d_inx};
    metabolites{i}.proton_id = RAW{i+1,p_inx};
    metabolites{i}.id_source = RAW{i+1,id_source_inx};
end
