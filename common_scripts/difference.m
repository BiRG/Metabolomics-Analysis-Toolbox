% Looks like this is only used by code in the Old-Files-and-Folders
% directory. Maybe we should move it out?

% Compute the difference between samples in a collection
collection = get_collection;

time_base = input('Enter base time: ');
time_target = input('Enter target time: ');
classification1 = input('Enter classification: ','s');

% Group the data
inxs_unpaired1 = [];
data_unpaired1 = [];
inxs_paired1 = [];
data_paired1 = [];
for i = 1:collection.num_samples
    if strcmp(collection.classification{i},classification1) && collection.time(i) == time_base
        inxs_unpaired1(end+1) = i;
        data_unpaired1(:,end+1) = collection.Y(:,i);
    end
    if strcmp(collection.classification{i},classification1) && collection.time(i) == time_target
        inxs_paired1(end+1) = i;
        data_paired1(:,end+1) = collection.Y(:,i);
    end
end

% Pair up the data
inxs_pairing1 = [];
data_pairing1 = [];
for i = 1:length(inxs_unpaired1)
    inx_unpaired = inxs_unpaired1(i);
    % Now find matching subject ID
    found = false;
    for j = 1:length(inxs_paired1)
        inx_paired = inxs_paired1(j);
        % Check for match - special casing the situation where the ids are strings and
        % where they are not
        if iscell(collection.subject_id)
           is_matching_id = strcmp(collection.subject_id{inx_paired}, ...
                collection.subject_id{inx_unpaired}) && ...
                inx_paired ~= inx_unpaired;
        else
            is_matching_id = ...
                collection.subject_id(inx_paired) == collection.subject_id(inx_unpaired) && ...
                inx_paired ~= inx_unpaired;
        end

        if is_matching_id
            inxs_pairing1(end+1,:) = [inx_unpaired,inx_paired];
            data_pairing1(:,end+1) = collection.Y(:,inx_unpaired) - collection.Y(:,inx_paired);
            found = true;
        end
    end
    if ~found
        if iscell(collection.subject_id)
            fprintf('Could not match sample %s for classification: %s\n',collection.subject_id{inx_unpaired},classification1);
        else
            fprintf('Could not match sample %d for classification: %s\n',collection.subject_id(inx_unpaired),classification1);
        end
    end
end
inxs_pairing2 = [];
data_pairing2 = [];
for i = 1:length(inxs_unpaired2)
    inx_unpaired = inxs_unpaired2(i);
    % Now find matching subject ID
    found = false;
    for j = 1:length(inxs_paired2)
        inx_paired = inxs_paired2(j);
        % Check for match - special casing the situation where the ids are strings and
        % where they are not
        if iscell(collection.subject_id)
           is_matching_id = strcmp(collection.subject_id{inx_paired}, ...
                collection.subject_id{inx_unpaired}) && ...
                inx_paired ~= inx_unpaired;
        else
            is_matching_id = ...
                collection.subject_id(inx_paired) == collection.subject_id(inx_unpaired) && ...
                inx_paired ~= inx_unpaired;
        end

        if is_matching_id
            inxs_pairing2(end+1,:) = [inx_unpaired,inx_paired];
            data_pairing2(:,end+1) = collection.Y(:,inx_unpaired) - collection.Y(:,inx_paired);
            found = true;
        end
    end
    if ~found
        if iscell(collection.subject_id)
            fprintf('Could not match sample %s for classification: %s\n',collection.subject_id{inx_unpaired},classification1);
        else
            fprintf('Could not match sample %d for classification: %s\n',collection.subject_id(inx_unpaired),classification1);
        end
    end
end

% Information for each bin
bins = {};
[num_bins,ncols] = size(collection.Y);
C = {};
C{1} = 'No multiple test correction';
C{2} = 'Bonferroni';
C{3} = 'Benjamini-Hochberg False Discovery Rate';
C{4} = 'Westfall-Young';
H = {};
H{1} = sprintf('Unpaired (%s vs. %s) at time %d',classification1,classification2,time_unpaired);
H{2} = sprintf('Paired (%d vs. %d) for %s',time_unpaired, time_paired, classification1);
H{3} = sprintf('Paired (%d vs. %d) for %s',time_unpaired, time_paired, classification2);
A = [];
% Output results
for i = 1:num_bins
    [h,p] = ttest2(data_unpaired1(i,:),data_unpaired2(i,:));
    bins{i}.unpaired_pvalue = p;
    A(i,1) = p;
    
    [h,p] = ttest(data_pairing1(i,:));
    bins{i}.paired_pvalue1 = p;
    A(i,2) = p;

    [h,p] = ttest(data_pairing2(i,:));
    bins{i}.paired_pvalue2 = p;
    A(i,3) = p;
end
R = []; % Ranking
S = []; % Sorted
I = [];
WY = []; % Westfall-Young
[S(:,1),I(:,1)] = sort(A(:,1),'descend');
R(I(:,1),1) = [1:num_bins]';
WY(:,1) = minP(S(end:-1:1,1),length(inxs_unpaired1)+length(inxs_unpaired2));
WY(I(end:-1:1,1),1) = WY(:,1);
[S(:,2),I(:,2)] = sort(A(:,2),'descend');
WY(:,2) = minP(S(end:-1:1,2),length(inxs_pairing1));
WY(I(end:-1:1,2),2) = WY(:,2);
R(I(:,2),2) = [1:num_bins]';
[S(:,3),I(:,3)] = sort(A(:,3),'descend');
WY(:,3) = minP(S(end:-1:1,3),length(inxs_pairing2));
WY(I(end:-1:1,3),3) = WY(:,3);
R(I(:,3),3) = [1:num_bins]';

[filename,pathname] = uiputfile({'*.txt'},'Save as');
fid = fopen([pathname,filename],'w');
for c = 1:length(C)
    for h = 1:length(H)
        if c == 1 && h == 1
            fprintf(fid,'\t');
        end
        if c > 1
            fprintf(fid,'\t');
        end
    end
    fprintf(fid,'%s',C{c});
end
fprintf(fid,'\n');
for c = 1:length(C)
    for h = 1:length(H)
        if h == 1 && c == 1
            fprintf(fid,'\t%s',H{h});
        else
            fprintf(fid,'\t%s',H{h});
        end
    end
end
fprintf(fid,'\n');
for i = 1:num_bins
    for c = 1:length(C)
        if c == 1 % No correction
            for h = 1:length(H)
                if h == 1 && c == 1
                    fprintf(fid,'%f\t%f',collection.x(i),A(i,h));
                else
                    fprintf(fid,'\t%f',A(i,h));
                end
            end
        elseif c == 2 % Bonferroni
            for h = 1:length(H)
                fprintf(fid,'\t%f',min([1,A(i,h)*num_bins]));
            end
        elseif c == 3 % Benjamini-Hochberg
            for h = 1:length(H)
                fprintf(fid,'\t%f',min([1,A(i,h)*num_bins/(num_bins - R(i,h) + 1)]));
            end
        elseif c == 4 % Westfall-Young
            for h = 1:length(H)
                fprintf(fid,'\t%f',WY(i,h));
            end
        end
    end
    fprintf(fid,'\n');
end
fclose(fid);
