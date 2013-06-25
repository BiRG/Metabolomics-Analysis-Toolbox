function investigate_property_probabilities( num_objects, num_property_x, num_property_y, num_iterations)
% Simulate some properties on objects and print several conditional probabilities
%
% There is a set of num_objects objects. num_property_x pairs of these
% objects are related by property x and num_property_y pairs are related
% by property y. For simplicity the objects will be positive numbers from
% 1..num_objects. DB1 randomly selects a pair from property x and negates
% the objects (so if 1,5 was selected then -1,-5 would be the contents of
% DB1). DB2x randomly selects a pair from property x. DB2y randomly 
% selects a pair from property y. SA (same as) selects one object n and
% contains the pair (-n,n)

assert(num_property_x <= num_objects*num_objects);
assert(num_property_y <= num_objects*num_objects);

fprintf('The confidence intervals presented are central 99%% confidence\n');
fprintf('intervals for the calculated binomial proportions.\n');
fprintf('\n');

num_mat_entries = num_objects*num_objects;
p1_mat = zeros(num_objects,num_objects);
p2_mat = p1_mat;

n1 = 0;
while(n1 < num_property_x)
    p1_mat(randi(num_mat_entries)) = 1;
    n1 = sum(p1_mat);
end

n2 = 0;
while(n2 < num_property_x)
    p2_mat(randi(num_mat_entries)) = 1;
    n2 = sum(p2_mat);
end



end

