function [permutations, testalpha, fold, data, features, class_labels, class_numbers] = read_file(file_name);

fid = fopen(file_name, 'r');

%default values
permutations = -1;
testalpha = -1;
fold = -1;
data = [];
% features = 'x1, x2, x3';
% class_labels = 'pre, pre, post';

while feof(fid) == 0
    line = fgetl(fid);
    
    %find permutation
    if findstr(line, 'permutations') > 0
        permutations = str2num(char(regexp(line, '\d+', 'match')));
    end;
    
    %find talpha
    if findstr(line, 'testalpha') > 0
        testalpha = str2num(char(regexp(line, '\d+.\d+', 'match')));
    end;
    
    %find fold
    if findstr(line, 'fold') > 0
        fold = str2num(char(regexp(line, '\d+', 'match')));
	if fold == 1
		fold = -1;
	end
    end;
    
    %find data
    if findstr(line, 'data') > 0
        fields = split(line,':');      
        temp1 = fields{2};
        data = str2num(temp1);
    end;
    
    %find #labels
    if findstr(line, 'class_numbers') > 0
        fields = split(line,':');      
        temp1 = fields{2};
        class_numbers = str2num(temp1);
    end;   
    
    %find label names
    if findstr(line, 'class_labels') > 0
        class_labels = line;
    end;   
    
    %find feature names
    if findstr(line, 'features') > 0
        temp2 = split(line, ':');
        features = split(temp2{2},', ');
    end;   
    
end;
fclose(fid);
