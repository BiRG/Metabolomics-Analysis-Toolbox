function intersected = intersect_x_vectors( collections )
% Returns collections with all x values that were absent in some spectrum removed
%
% intersected = INTERSECT_X_VECTORS(collection)
%
% -------------------------------------------------------------------------
% Input arguments
% -------------------------------------------------------------------------
% 
% collections - a cell array of spectral collections. Each spectral
%               collection is a struct. This is the format
%               of the return value of load_collections.m in
%               common_scripts. 
% -------------------------------------------------------------------------
% Output parameters
% -------------------------------------------------------------------------
% 
% intersected - like collections, except for all i intersected{i}.x(i) is
%              present only if for all j collections{j}.x contained 
%              intersected{i}.x(i)
% -------------------------------------------------------------------------
% Example
% -------------------------------------------------------------------------
%
% >> s1.x = [1, 2, 3]; s1.Y = [1; 2; 3]; 
% >> s2.x = [0, 1, 2, 3, 4]; s2.Y = [0; 2; 4; 6; 8];
% >> s3.x = [0, 1, 3, 4]; s3.Y = [0; 3; 9; 12];
% >> s4.x = [0, 1, 3, 4]; s4.Y = [0,0; 3,8; 9,24; 12,32];
% >> a=intersect_x_vectors({s1,s2,s3});
%
% a{1}.x == [1, 3]&& a{1}.Y == [1; 3];
% a{2}.x == [1, 3]&& a{2}.Y == [2; 6];
% a{3}.x == [1, 3]&& a{3}.Y == [3; 9];
% a{1}.processing_log == a{2}.processing_log == a{3}.processing_log
% a{1}.processing_log == 'Intersected x coordinate vectors.'
%
%
%
% >> s1.x = [1, 2, 3]; s1.Y = [1; 2; 3]; 
% >> s2.x = [0, 1, 2, 3, 4]; s2.Y = [0; 2; 4; 6; 8];
% >> s3.x = [0, 1, 3, 4]; s3.Y = [0; 3; 9; 12];
% >> s4.x = [0, 1, 3, 4]; s4.Y = [0,0; 3,8; 9,24; 12,32];
% >> a=intersect_x_vectors({s2,s3});
%
% a{1}.x == [0, 1, 3, 4]&& a{1}.Y == [0; 2; 6; 8];
% a{2}.x == [0, 1, 3, 4]&& a{2}.Y == [0; 3; 9; 12];
% a{1}.processing_log == a{2}.processing_log == a{3}.processing_log
% a{1}.processing_log == 'Intersected x coordinate vectors.'
%
%
%
% >> s1.x = [1, 2, 3]; s1.Y = [1; 2; 3]; 
% >> s2.x = [0, 1, 2, 3, 4]; s2.Y = [0; 2; 4; 6; 8];
% >> s3.x = [0, 1, 3, 4]; s3.Y = [0; 3; 9; 12];
% >> s4.x = [0, 1, 3, 4]; s4.Y = [0,0; 3,8; 9,24; 12,32];
% >> a=intersect_x_vectors({s2,s4});
%
% a{1}.x == [0, 1, 3, 4]&& a{1}.Y == [0; 2; 6; 8];
% a{2}.x == [0, 1, 3, 4]&& a{2}.Y == [0,0; 3,8; 9,24; 12,32];
% a{1}.processing_log == a{2}.processing_log == a{3}.processing_log
% a{1}.processing_log == 'Intersected x coordinate vectors.'
%
%
% >> a=intersect_x_vectors({});
%
% a == {}
%
% -------------------------------------------------------------------------
% Authors
% -------------------------------------------------------------------------
%
% Eric Moyer (July 2012) eric_moyer@yahoo.com
%

% Deal with empty collections
if isempty(collections)
    intersected = collections;
    return;
end

% Calculate the new x values
new_x = collections{1}.x;
for c = 2:length(collections)
    new_x = intersect(collections{c}.x, new_x);
end

% Extract only those x values for the intersected collections
intersected = collections;
for c = 1:length(collections)
    [unused, indices_to_keep] = intersect(collections{c}.x, new_x); %#ok<ASGLU>
    intersected{c}.x = new_x;
    intersected{c}.Y = collections{c}.Y(indices_to_keep, :);
end

intersected = append_to_processing_log(intersected, 'Intersected x coordinate vectors.');

end

