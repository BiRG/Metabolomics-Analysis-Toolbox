function dilutions = rand_dilutions( num_dilutions, range )
% Return a random column vector of length num_dilutions uniformly distributed in range
% 
% 

d=range(2)-range(1);
dilutions = rand(num_dilutions, 1).*d+range(1);

end

