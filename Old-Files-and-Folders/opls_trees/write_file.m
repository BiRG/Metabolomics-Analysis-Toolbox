function [] = write_file(fold,accuracy,mean_class_numbers,W,data,b,C,R2_X,R2_Y,class_numbers0,P,class_numbers,means_data,T_ortho,P_ortho,stdev_class_numbers,data0,stdevs_data,T,U,num_opls_fact,press,q2,testalpha,permutations,class_labels,features,perm_sorted_weights,perm_weights,perm_q2s,significant_features,SE,Y_pred,outfile);

fid = fopen(outfile, 'w');

%write permutations
fprintf(fid, 'permutations: %d\n', permutations);

%write fold
fprintf(fid, 'fold: %d\n', fold);

%write accuracy
fprintf(fid, 'accuracy: %.16f\n', accuracy);

%write SE
data2 = SE(:,1:length(P)-1);
data3 = SE(:,length(P));
str1 = num2str(data2,'%.16f,');
str2 = num2str(data3,'%.16f');
str3 = strcat(str1,str2);
temp = '';
for i=1:fold-1
    temp = strcat(temp, str3(i,:),';');
end;
fprintf(fid, 'SE: %s%s\n', temp, str3(fold,:));

%write mean_class_numbers
fprintf(fid, 'model[''mean_class_numbers'']: %.16f\n', mean_class_numbers);

%write W
temp = strcat(num2str(W(1:end-1)','%.16f;'),num2str(W(end)','%.16f'));
fprintf(fid, 'model[''W'']: %s\n', temp);

%write data
data2 = data(:,1:length(P)-1);
data3 = data(:,length(P));
str1 = num2str(data2,'%.16f,');
str2 = num2str(data3,'%.16f');
str3 = strcat(str1,str2);
temp = '';
for i=1:length(class_numbers)-1
    temp = strcat(temp, str3(i,:),';');
end;
fprintf(fid, 'model[''data'']: %s%s\n', temp, str3(length(class_numbers),:));

%write b
temp = strcat(num2str(b(1:end-1)','%.16f;'),num2str(b(end)','%.16f'));
fprintf(fid, 'model[''b'']: %s\n', temp);

%write C
temp = strcat(num2str(C(1:end-1)','%.16f;'),num2str(C(end)','%.16f'));
fprintf(fid, 'model[''C'']: %s\n', temp);

%write R2_X
fprintf(fid, 'model[''R2_X'']: %.16f\n', R2_X);

%write R2_Y
fprintf(fid, 'model[''R2_Y'']: %.16f\n', R2_Y);

%write class_numbers0
temp = strcat(num2str(class_numbers0(1:end-1)','%.16f;'),num2str(class_numbers0(end)','%.16f'));
fprintf(fid, 'model[''class_numbers0'']: %s\n', temp);

%write P
temp = strcat(num2str(P(1:end-1)','%.16f;'),num2str(P(end)','%.16f'));
fprintf(fid, 'model[''P'']: %s\n', temp);

%write class_numbers
temp = strcat(num2str(class_numbers(1:end-1)','%.16f;'),num2str(class_numbers(end)','%.16f'));
fprintf(fid, 'model[''class_numbers'']: %s\n', temp);

%write means_data
temp = strcat(num2str(means_data(1:end-1),'%.16f;'),num2str(means_data(end),'%.16f'));
fprintf(fid, 'model[''means_data'']: %s\n', temp);

%write T_ortho
if num_opls_fact==0
    T_ortho = zeros(length(class_numbers),1);
    str3 = num2str(T_ortho,'%d');
    temp = '';
    for i=1:length(class_numbers)-1
        temp = strcat(temp, str3(i,:),';');
    end;
    fprintf(fid, 'model[''T_ortho'']: %s%s\n', temp, str3(length(class_numbers),:));
else
    fprintf(fid, 'model[''T_ortho'']: ');
    [rows,cols] = size(T_ortho);
    for i = 1:rows
      if i > 1
        fprintf(fid, '; ');
      end
      for j = 1:cols
        if j == 1
          fprintf(fid, '%.16f', T_ortho(i,j));
        else
          fprintf(fid, ',%.16f', T_ortho(i,j));
        end
      end
    end
    fprintf(fid,'\n');
end

%write P_ortho
if num_opls_fact==0
    P_ortho = zeros(length(class_numbers),1);
    str3 = num2str(P_ortho,'%d');
    temp = '';
    for i=1:length(class_numbers)-1
        temp = strcat(temp, str3(i,:),';');
    end;
    fprintf(fid, 'model[''P_ortho'']: %s%s\n', temp, str3(length(class_numbers),:));
else
    fprintf(fid, 'model[''P_ortho'']: ');
    [rows,cols] = size(P_ortho);
    for i = 1:rows
      if i > 1
        fprintf(fid, '; ');
      end
      for j = 1:cols
        if j == 1
          fprintf(fid, '%.16f', P_ortho(i,j));
        else
          fprintf(fid, ',%.16f', P_ortho(i,j));
        end
      end
    end
    fprintf(fid,'\n');
end

%write stdev_class_numbers
fprintf(fid, 'model[''stdev_class_numbers'']: %.16f\n', stdev_class_numbers);

%write data0
data2 = data(:,1:length(P)-1);
data3 = data(:,length(P));
str1 = num2str(data2,'%.16f,');
str2 = num2str(data3,'%.16f');
str3 = strcat(str1,str2);
temp = '';
for i=1:length(class_numbers-1)
    temp = strcat(temp, str3(i,:),';');
end;
fprintf(fid, 'model[''data0'']: %s%s\n', temp, str3(length(class_numbers),:));

%write stdevs_data
fprintf(fid, 'model[''stdevs_data'']: %s\n', temp);

%write Y_pred
temp = strcat(num2str(Y_pred(1:end-1)','%.16f;'),num2str(Y_pred(end)','%.16f'));
fprintf(fid, 'model[''Y_pred'']: %s\n', temp);

%write T
temp = strcat(num2str(T(1:end-1)','%.16f;'),num2str(T(end)','%.16f'));
fprintf(fid, 'model[''T'']: %s\n', temp);

%write U
temp = strcat(num2str(U(1:end-1)','%.16f;'),num2str(U(end)','%.16f'));
fprintf(fid, 'model[''U'']: %s\n', temp);

%write num_opls_fact
fprintf(fid, 'num_opls_fact: %d\n', num_opls_fact);

%write press
fprintf(fid, 'press: %.16f\n', press);

%write q2
fprintf(fid, 'q2: %.16f\n', q2);

%write testalpha
fprintf(fid, 'testalpha: %.16f\n', testalpha);

%write class_labels
fprintf(fid, '%s\n', class_labels);

%write features
if isempty(features)
    fprintf(fid, 'features: \n');
else
    temp = features{1};
    for i=2:length(features)
        temp = strcat(strcat(temp,','), features{i});
    end
    fprintf(fid, 'features: %s\n', temp);
end


%write perm_sorted_weights
data2 = data(:,1:length(P)-1);
data3 = data(:,length(P));
str1 = num2str(data2,'%.16f,');
str2 = num2str(data3,'%.16f');
str3 = strcat(str1,str2);
temp = '';
for i=1:length(permutations-1)
    temp = strcat(temp, str3(i,:),';');
end;
fprintf(fid, 'model[''perm_sorted_weights'']: %s%s\n', temp, str3(length(permutations),:));

%write perm_weights
data2 = data(:,1:length(P)-1);
data3 = data(:,length(P));
str1 = num2str(data2,'%.16f,');
str2 = num2str(data3,'%.16f');
str3 = strcat(str1,str2);
temp = '';
for i=1:length(permutations-1)
    temp = strcat(temp, str3(i,:),';');
end;
fprintf(fid, 'model[''perm_weights'']: %s%s\n', temp, str3(length(permutations),:));

%write perm_q2s
temp = strcat(num2str(perm_q2s(1:end-1)','%.16f;'),num2str(perm_q2s(end)','%.16f'));
fprintf(fid, 'perm_q2s: %s\n', temp);

%write significant_features
if isempty(significant_features)
    fprintf(fid, 'significant_features: \n');
else
    temp = features{significant_features(1)};
    for i=2:length(significant_features)
        temp = strcat(strcat(temp,','), features{significant_features(i)});
    end
    fprintf(fid, 'significant_features: %s\n', temp);
end

fclose(fid);

