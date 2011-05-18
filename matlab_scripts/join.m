function str = join(ary,dlm)
str = '';
for i = 1:length(ary)
    if i == 1
        str = ary{i};
    else
        str = [str,dlm,ary{i}];
    end
end