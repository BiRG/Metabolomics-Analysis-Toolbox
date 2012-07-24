function o = horzcat_structs( s1, s2 )
% Return a structure where field f contains horzcat(s1.(f), s2.(f))
%
% For each field that is in both s1 and s2, the resulting structure
% contains the horizontal concatenation of the value of that field in s1 
% and of that field in s2.
%
% If a field is only present in one of s1 and s2, then the result contains
% that field verbatim.
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% s1 - a struct
%
% s2 - a struct
%
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% o - a struct with fields that are the union of the fields in s1 and s2.
%     The contents of those fields are contained in the description
%
% -------------------------------------------------------------------------
% Examples
% -------------------------------------------------------------------------
%
% >> f.a='abc'; f.b=1; f.c=[1,2,3];
% >> g.a='xyz'; g.x=26; g.c=[24,25,26];
% >> horzcat_structs(f,g)
%
% ans = 
% 
%     a: 'abcxyz'
%     b: 1
%     c: [1 2 3 24 25 26]
%     x: 26
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%


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

