function results = run_deconvolution(x,Y,BETA0)
create_hadoop_input(x,Y,BETA0,'hadoop_input.txt');

fid = fopen('hadoop_input.txt','r');
stdin = char(fread(fid,[1,Inf],'char'));
fclose(fid);

mapper(stdin,'mapper_output.txt');
 
fid = fopen('mapper_output.txt','r');
stdin = char(fread(fid,[1,Inf],'char'));
fclose(fid);

results = reducer(x,Y,stdin);