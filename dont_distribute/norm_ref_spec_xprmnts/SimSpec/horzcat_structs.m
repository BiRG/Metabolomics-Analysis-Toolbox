function o = horzcat_structs( s1, s2 )
%HORZCAT_STRUCTS stub (but probably working)

fields = unique(horzcat(fieldnames(s1), fieldnames(s2)));
for i=1:length(fields)
    f=fields{i};
    if isfield(s1, f)
        if isfield(s2, f)
            o.(f)=horzcat(s1.(f), s2.(f));
        else
            o.(f)=s1.(f);
        end
    else
        o.(f)=s2.(f);
    end
end

end

